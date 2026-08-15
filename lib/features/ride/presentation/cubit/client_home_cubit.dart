import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';
import '../../../../core/utils/fare_calculator.dart';

import '../../domain/entities/ride_location.dart';
import '../../domain/usecase/cancel_ride_usecase.dart';
import '../../domain/usecase/request_ride_usecase.dart';
import '../../domain/usecase/watch_ride_usecase.dart';

import 'client_home_state.dart';

class ClientHomeCubit extends Cubit<ClientHomeState> {
  final String riderId;
  final String riderName;
  final String riderPhone;

  final LocationService locationService;
  final RequestRideUseCase requestRideUseCase;
  final WatchRideUseCase watchRideUseCase;
  final CancelRideUseCase cancelRideUseCase;

  StreamSubscription? _rideSub;

  ClientHomeCubit({
    required this.riderId,
    required this.riderName,
    required this.riderPhone,
    required this.locationService,
    required this.requestRideUseCase,
    required this.watchRideUseCase,
    required this.cancelRideUseCase,
  }) : super(const ClientHomeState());

  Future<void> loadCurrentLocation() async {
    emit(state.copyWith(isLoadingLocation: true, clearError: true));

    try {
      final position = await locationService.getCurrentPosition();

      final address = await locationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      final pickup = RideLocation(
        lat: position.latitude,
        lng: position.longitude,
        address: address,
      );

      emit(
        state.copyWith(
          isLoadingLocation: false,
          pickup: pickup,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(isLoadingLocation: false, errorMessage: e.toString()),
      );
    }
  }

  void setPickup(RideLocation pickup) {
    emit(state.copyWith(pickup: pickup, clearError: true));

    if (state.destination != null) {
      _recalculateFare(pickup: pickup, destination: state.destination!);
    }
  }

  Future<void> selectDestinationFromMap(double lat, double lng) async {
    try {
      emit(state.copyWith(isSearchingDestination: true, clearError: true));

      final address = await locationService.getAddressFromCoordinates(lat, lng);

      final destination = RideLocation(
        lat: lat,
        lng: lng,
        address: address ?? 'الموقع المحدد على الخريطة',
      );

      _applyDestination(destination);
    } catch (e) {
      emit(
        state.copyWith(
          isSearchingDestination: false,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _applyDestination(RideLocation destination) {
    final pickup = state.pickup;

    if (pickup == null) {
      emit(
        state.copyWith(
          isSearchingDestination: false,
          errorMessage: 'حدد مكان الاستلام الأول.',
        ),
      );
      return;
    }

    _recalculateFare(pickup: pickup, destination: destination);
  }

  void _recalculateFare({
    required RideLocation pickup,
    required RideLocation destination,
  }) {
    final distanceKm = locationService.distanceInKm(
      startLat: pickup.lat,
      startLng: pickup.lng,
      endLat: destination.lat,
      endLng: destination.lng,
    );

    final fare = FareCalculator.estimate(distanceKm);

    emit(
      state.copyWith(
        isSearchingDestination: false,
        destination: destination,
        distanceKm: distanceKm,
        estimatedFare: fare,
        clearError: true,
      ),
    );
  }

  void clearDestination() {
    emit(state.copyWith(clearDestination: true, clearError: true));
  }

  Future<void> confirmRideRequest() async {
    final pickup = state.pickup;
    final destination = state.destination;
    final distanceKm = state.distanceKm;
    final estimatedFare = state.estimatedFare;

    if (pickup == null) {
      emit(state.copyWith(errorMessage: 'حدد مكان الاستلام.'));
      return;
    }

    if (destination == null) {
      emit(state.copyWith(errorMessage: 'حدد وجهتك.'));
      return;
    }

    if (distanceKm == null || estimatedFare == null) {
      return;
    }

    emit(state.copyWith(isRequesting: true, clearError: true));

    final result = await requestRideUseCase(
      riderId: riderId,
      riderName: riderName,
      riderPhone: riderPhone,
      pickup: pickup,
      destination: destination,
      distanceKm: distanceKm,
      estimatedFare: estimatedFare,
    );

    result.fold(_emitFailure, (ride) {
      emit(
        state.copyWith(isRequesting: false, activeRide: ride, clearError: true),
      );

      _listenToRide(ride.id);
    });
  }

  void _listenToRide(String rideId) {
    _rideSub?.cancel();

    _rideSub = watchRideUseCase(rideId).listen((result) {
      result.fold(_emitFailure, (ride) {
        if (ride == null) {
          _rideSub?.cancel();

          emit(
            state.copyWith(
              clearActiveRide: true,
              errorMessage: 'الرحلة لم تعد موجودة.',
            ),
          );

          return;
        }

        if (ride.status.isCompleted || ride.status.isCancelled) {
          _rideSub?.cancel();
        }

        emit(state.copyWith(activeRide: ride, clearError: true));
      });
    });
  }

  Future<void> cancelActiveRide() async {
    final ride = state.activeRide;

    if (ride == null) {
      return;
    }

    emit(state.copyWith(isRequesting: true, clearError: true));

    final result = await cancelRideUseCase(ride.id);

    result.fold(_emitFailure, (_) {
      _rideSub?.cancel();

      emit(
        state.copyWith(
          isRequesting: false,
          clearActiveRide: true,
          clearDestination: true,
          clearError: true,
        ),
      );
    });
  }

  void dismissFinishedRide() {
    _rideSub?.cancel();

    emit(ClientHomeState(pickup: state.pickup));
  }

  void _emitFailure(Failure failure) {
    emit(
      state.copyWith(
        isRequesting: false,
        isSearchingDestination: false,
        errorMessage: failure.message,
      ),
    );
  }

  @override
  Future<void> close() {
    _rideSub?.cancel();
    return super.close();
  }
}
