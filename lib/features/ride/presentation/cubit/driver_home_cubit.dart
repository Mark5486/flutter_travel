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

  // ============================================================
  // ONLINE / OFFLINE
  // ============================================================

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
      print('========== GO ONLINE START ==========');

      // ----------------------------------------------------------
      // 1. GET CURRENT LOCATION
      // ----------------------------------------------------------

      print('1 - Getting current position...');

      final position = await locationService.getCurrentPosition();

      final driverLocation = LatLng(position.latitude, position.longitude);

      print(
        '2 - POSITION: '
        '${position.latitude}, '
        '${position.longitude}',
      );

      // ----------------------------------------------------------
      // 2. SAVE AVAILABILITY
      // ----------------------------------------------------------

      print('3 - Calling setDriverAvailability...');

      final result = await setDriverAvailabilityUseCase(
        driverId: driverId,
        driverName: driverName,
        isOnline: true,
        lat: position.latitude,
        lng: position.longitude,
      );

      print('4 - setDriverAvailability returned');

      result.fold(
        (failure) {
          print(
            '5 - AVAILABILITY FAILURE: '
            '${failure.message}',
          );

          _emitFailure(failure);
        },
        (_) {
          print('5 - AVAILABILITY SUCCESS');

          // ------------------------------------------------------
          // IMPORTANT:
          // هنا بنحط موقع السواق في الـ STATE
          // ------------------------------------------------------

          emit(
            state.copyWith(
              isOnline: true,
              isProcessing: false,
              driverLocation: driverLocation,
              clearError: true,
            ),
          );

          // ------------------------------------------------------
          // 3. LISTEN REQUESTS
          // ------------------------------------------------------

          print('6 - Listening to incoming requests...');

          _listenToIncomingRequests();

          // ------------------------------------------------------
          // 4. LISTEN DRIVER LOCATION
          // ------------------------------------------------------

          print('7 - Listening to driver location...');

          _listenToPosition();

          print('========== GO ONLINE DONE ==========');
        },
      );
    } catch (e, stackTrace) {
      print('========== GO ONLINE EXCEPTION ==========');
      print(e);
      print(stackTrace);

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

  // ============================================================
  // DRIVER LOCATION
  // ============================================================

  void _listenToPosition() {
    _positionSub?.cancel();

    _positionSub = locationService.watchPosition().listen(
      (position) async {
        final driverLocation = LatLng(position.latitude, position.longitude);

        print(
          'DRIVER LOCATION UPDATE: '
          '${position.latitude}, '
          '${position.longitude}',
        );

        // --------------------------------------------------------
        // UPDATE UI MAP
        // --------------------------------------------------------

        emit(state.copyWith(driverLocation: driverLocation, clearError: true));

        // --------------------------------------------------------
        // UPDATE FIRESTORE
        // --------------------------------------------------------

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

  // ============================================================
  // INCOMING REQUESTS
  // ============================================================

  void _listenToIncomingRequests() {
    _incomingSub?.cancel();

    _incomingSub = watchIncomingRequestsUseCase(driverId).listen(
      (result) {
        result.fold(_emitFailure, (rides) {
          if (state.activeRide != null) {
            return;
          }

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

  // ============================================================
  // ACTIVE RIDE
  // ============================================================

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
        });
      },
      onError: (error) {
        emit(state.copyWith(errorMessage: error.toString()));
      },
    );
  }

  // ============================================================
  // ACCEPT
  // ============================================================

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

  // ============================================================
  // REJECT
  // ============================================================

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

  // ============================================================
  // ARRIVED
  // ============================================================

  Future<void> markArrived() async {
    final ride = state.activeRide;

    if (ride == null) return;
    if (state.isProcessing) return;

    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await driverArrivedUseCase(ride.id);

    result.fold(_emitFailure, (_) {
      emit(state.copyWith(isProcessing: false, clearError: true));
    });
  }

  // ============================================================
  // START TRIP
  // ============================================================

  Future<void> startTrip() async {
    final ride = state.activeRide;

    if (ride == null) return;
    if (state.isProcessing) return;

    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await startTripUseCase(ride.id);

    result.fold(_emitFailure, (_) {
      emit(state.copyWith(isProcessing: false, clearError: true));
    });
  }

  // ============================================================
  // COMPLETE
  // ============================================================

  Future<void> completeActiveRide() async {
    final ride = state.activeRide;

    if (ride == null) return;
    if (state.isProcessing) return;

    emit(state.copyWith(isProcessing: true, clearError: true));

    final result = await completeRideUseCase(ride.id);

    result.fold(_emitFailure, (_) {
      emit(state.copyWith(isProcessing: false, clearError: true));
    });
  }

  // ============================================================
  // ERROR
  // ============================================================

  void _emitFailure(Failure failure) {
    emit(state.copyWith(isProcessing: false, errorMessage: failure.message));
  }

  // ============================================================
  // CLOSE
  // ============================================================

  @override
  Future<void> close() async {
    await _incomingSub?.cancel();
    await _activeRideSub?.cancel();
    await _positionSub?.cancel();

    return super.close();
  }
}
