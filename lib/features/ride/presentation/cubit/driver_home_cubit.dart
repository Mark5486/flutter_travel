import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/services/location_service.dart';

import '../../domain/entities/ride.dart';

import '../../domain/usecase/accept_ride_usecase.dart';
import '../../domain/usecase/complete_ride_usecase.dart';
import '../../domain/usecase/driver_arrived_usecase.dart';
import '../../domain/usecase/reject_ride_usecase.dart';
import '../../domain/usecase/set_driver_availability_usecase.dart';
import '../../domain/usecase/start_trip_usecase.dart';
import '../../domain/usecase/update_driver_location_usecase.dart';
import '../../domain/usecase/watch_active_ride_for_driver_usecase.dart';
import '../../domain/usecase/watch_incoming_requests_usecase.dart';

import 'driver_home_state.dart';

class DriverHomeCubit extends Cubit<DriverHomeState> {
  final String driverId;
  final String driverName;
  final String driverPhone;

  final LocationService locationService;

  final SetDriverAvailabilityUseCase setDriverAvailabilityUseCase;

  final UpdateDriverLocationUseCase updateDriverLocationUseCase;

  final WatchIncomingRequestsUseCase watchIncomingRequestsUseCase;

  final WatchActiveRideForDriverUseCase watchActiveRideForDriverUseCase;

  final AcceptRideUseCase acceptRideUseCase;
  final RejectRideUseCase rejectRideUseCase;

  final DriverArrivedUseCase driverArrivedUseCase;
  final StartTripUseCase startTripUseCase;
  final CompleteRideUseCase completeRideUseCase;

  StreamSubscription? _incomingSub;
  StreamSubscription? _activeRideSub;
  StreamSubscription? _positionSub;

  DriverHomeCubit({
    required this.driverId,
    required this.driverName,
    required this.driverPhone,
    required this.locationService,
    required this.setDriverAvailabilityUseCase,
    required this.updateDriverLocationUseCase,
    required this.watchIncomingRequestsUseCase,
    required this.watchActiveRideForDriverUseCase,
    required this.acceptRideUseCase,
    required this.rejectRideUseCase,
    required this.driverArrivedUseCase,
    required this.startTripUseCase,
    required this.completeRideUseCase,
  }) : super(const DriverHomeState()) {
    _listenToActiveRide();
  }

  Future<void> loadDriverLocation() async {
    try {
      final position = await locationService.getCurrentPosition();

      emit(
        state.copyWith(
          driverLocation: LatLng(position.latitude, position.longitude),
          clearError: true,
        ),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  Future<void> toggleOnline(bool value) async {
    if (state.isProcessing) return;

    emit(state.copyWith(isProcessing: true, clearError: true));

    if (value) {
      await _goOnline();
    } else {
      await _goOffline();
    }
  }

  Future<void> _goOnline() async {
    try {
      final position = await locationService.getCurrentPosition();

      final driverLocation = LatLng(position.latitude, position.longitude);

      final result = await setDriverAvailabilityUseCase(
        driverId: driverId,
        driverName: driverName,
        isOnline: true,
        lat: position.latitude,
        lng: position.longitude,
      );

      result.fold(_emitFailure, (_) {
        emit(
          state.copyWith(
            isOnline: true,
            isProcessing: false,
            driverLocation: driverLocation,
            clearError: true,
          ),
        );

        _listenToIncomingRequests();
        _listenToPosition();
      });
    } catch (e) {
      emit(state.copyWith(isProcessing: false, errorMessage: e.toString()));
    }
  }

  Future<void> _goOffline() async {
    try {
      await _incomingSub?.cancel();
      await _positionSub?.cancel();

      _incomingSub = null;
      _positionSub = null;

      final result = await setDriverAvailabilityUseCase(
        driverId: driverId,
        driverName: driverName,
        isOnline: false,
      );

      result.fold(_emitFailure, (_) {
        emit(
          state.copyWith(
            isOnline: false,
            isProcessing: false,
            clearIncomingRequest: true,
            clearError: true,
          ),
        );
      });
    } catch (e) {
      emit(state.copyWith(isProcessing: false, errorMessage: e.toString()));
    }
  }

  void _listenToPosition() {
    _positionSub?.cancel();

    _positionSub = locationService.watchPosition().listen(
      (position) async {
        final driverLocation = LatLng(position.latitude, position.longitude);

        emit(state.copyWith(driverLocation: driverLocation, clearError: true));

        final result = await updateDriverLocationUseCase(
          driverId: driverId,
          lat: position.latitude,
          lng: position.longitude,
        );

        result.fold(_emitFailure, (_) {});
      },
      onError: (error) {
        emit(state.copyWith(errorMessage: error.toString()));
      },
    );
  }

  void _listenToIncomingRequests() {
    _incomingSub?.cancel();

    _incomingSub = watchIncomingRequestsUseCase(driverId).listen(
      (result) {
        result.fold(_emitFailure, (rides) {
          if (state.activeRide != null) return;

          if (rides.isEmpty) {
            emit(state.copyWith(clearIncomingRequest: true));
            return;
          }

          emit(state.copyWith(incomingRequest: rides.first, clearError: true));
        });
      },
      onError: (error) {
        emit(state.copyWith(errorMessage: error.toString()));
      },
    );
  }

  void _listenToActiveRide() {
    _activeRideSub?.cancel();

    _activeRideSub = watchActiveRideForDriverUseCase(driverId).listen(
      (result) {
        result.fold(_emitFailure, (ride) {
          if (ride == null) {
            emit(state.copyWith(clearActiveRide: true));
            return;
          }

          emit(
            state.copyWith(
              activeRide: ride,
              clearIncomingRequest: true,
              clearError: true,
            ),
          );

          if (!state.isOnline) {
            _goOnline();
          }
        });
      },
      onError: (error) {
        emit(state.copyWith(errorMessage: error.toString()));
      },
    );
  }

  Future<void> acceptRequest(Ride ride) async {
    if (state.isProcessing) return;

    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await acceptRideUseCase(
      rideId: ride.id,
      driverId: driverId,
      driverName: driverName,
      driverPhone: driverPhone,
    );

    result.fold(_emitFailure, (_) {
      emit(
        state.copyWith(
          isProcessing: false,
          clearIncomingRequest: true,
          clearError: true,
        ),
      );
    });
  }

  Future<void> rejectRequest(Ride ride) async {
    if (state.isProcessing) return;

    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await rejectRideUseCase(rideId: ride.id, driverId: driverId);

    result.fold(_emitFailure, (_) {
      emit(
        state.copyWith(
          isProcessing: false,
          clearIncomingRequest: true,
          clearError: true,
        ),
      );
    });
  }

  Future<void> markArrived() async {
    final ride = state.activeRide;

    if (ride == null || state.isProcessing) return;

    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await driverArrivedUseCase(ride.id);

    result.fold(_emitFailure, (_) {
      emit(state.copyWith(isProcessing: false, clearError: true));
    });
  }

  Future<void> startTrip() async {
    final ride = state.activeRide;

    if (ride == null || state.isProcessing) return;

    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await startTripUseCase(ride.id);

    result.fold(_emitFailure, (_) {
      emit(state.copyWith(isProcessing: false, clearError: true));
    });
  }

  Future<void> completeActiveRide() async {
    final ride = state.activeRide;

    if (ride == null || state.isProcessing) return;

    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await completeRideUseCase(ride.id);

    result.fold(_emitFailure, (_) {
      emit(
        state.copyWith(
          isProcessing: false,
          clearActiveRide: true,
          clearError: true,
        ),
      );
    });
  }

  void _emitFailure(Failure failure) {
    emit(state.copyWith(isProcessing: false, errorMessage: failure.message));
  }

  @override
  Future<void> close() async {
    await _incomingSub?.cancel();
    await _activeRideSub?.cancel();
    await _positionSub?.cancel();

    return super.close();
  }
}
