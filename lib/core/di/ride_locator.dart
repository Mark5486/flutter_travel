import 'package:get_it/get_it.dart';

import '../../core/services/location_service.dart';

import '../../features/ride/data/datasources/ride_remote_data_source.dart';
import '../../features/ride/data/repositories/ride_repository_impl.dart';

import '../../features/ride/domain/repositories/ride_repository.dart';

import '../../features/ride/domain/usecase/accept_ride_usecase.dart';
import '../../features/ride/domain/usecase/cancel_ride_usecase.dart';
import '../../features/ride/domain/usecase/complete_ride_usecase.dart';
import '../../features/ride/domain/usecase/driver_arrived_usecase.dart';
import '../../features/ride/domain/usecase/reject_ride_usecase.dart';
import '../../features/ride/domain/usecase/request_ride_usecase.dart';
import '../../features/ride/domain/usecase/set_driver_availability_usecase.dart';
import '../../features/ride/domain/usecase/start_trip_usecase.dart';
import '../../features/ride/domain/usecase/update_driver_location_usecase.dart';
import '../../features/ride/domain/usecase/watch_active_ride_for_driver_usecase.dart';
import '../../features/ride/domain/usecase/watch_incoming_requests_usecase.dart';
import '../../features/ride/domain/usecase/watch_ride_usecase.dart';

final getIt = GetIt.instance;

void setupRideLocator() {
  // ==========================================================
  // LOCATION SERVICE
  // ==========================================================

  if (!getIt.isRegistered<LocationService>()) {
    getIt.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  }

  // ==========================================================
  // DATA SOURCE
  // ==========================================================

  if (!getIt.isRegistered<RideRemoteDataSource>()) {
    getIt.registerLazySingleton<RideRemoteDataSource>(
      () => RideRemoteDataSourceImpl(firebaseService: getIt()),
    );
  }

  // ==========================================================
  // REPOSITORY
  // ==========================================================

  if (!getIt.isRegistered<RideRepository>()) {
    getIt.registerLazySingleton<RideRepository>(
      () => RideRepositoryImpl(remoteDataSource: getIt()),
    );
  }

  // ==========================================================
  // RIDER
  // ==========================================================

  // Request Ride
  if (!getIt.isRegistered<RequestRideUseCase>()) {
    getIt.registerLazySingleton<RequestRideUseCase>(
      () => RequestRideUseCase(repository: getIt()),
    );
  }

  // Watch Ride
  if (!getIt.isRegistered<WatchRideUseCase>()) {
    getIt.registerLazySingleton<WatchRideUseCase>(
      () => WatchRideUseCase(repository: getIt()),
    );
  }

  // Cancel Ride
  if (!getIt.isRegistered<CancelRideUseCase>()) {
    getIt.registerLazySingleton<CancelRideUseCase>(
      () => CancelRideUseCase(repository: getIt()),
    );
  }

  // ==========================================================
  // DRIVER - WATCH
  // ==========================================================

  // Watch Incoming Requests
  if (!getIt.isRegistered<WatchIncomingRequestsUseCase>()) {
    getIt.registerLazySingleton<WatchIncomingRequestsUseCase>(
      () => WatchIncomingRequestsUseCase(repository: getIt()),
    );
  }

  // Watch Active Ride
  if (!getIt.isRegistered<WatchActiveRideForDriverUseCase>()) {
    getIt.registerLazySingleton<WatchActiveRideForDriverUseCase>(
      () => WatchActiveRideForDriverUseCase(repository: getIt()),
    );
  }

  // ==========================================================
  // DRIVER - RIDE ACTIONS
  // ==========================================================

  // Accept
  if (!getIt.isRegistered<AcceptRideUseCase>()) {
    getIt.registerLazySingleton<AcceptRideUseCase>(
      () => AcceptRideUseCase(repository: getIt()),
    );
  }

  // Reject
  if (!getIt.isRegistered<RejectRideUseCase>()) {
    getIt.registerLazySingleton<RejectRideUseCase>(
      () => RejectRideUseCase(repository: getIt()),
    );
  }

  // Driver Arrived
  if (!getIt.isRegistered<DriverArrivedUseCase>()) {
    getIt.registerLazySingleton<DriverArrivedUseCase>(
      () => DriverArrivedUseCase(repository: getIt()),
    );
  }

  // Start Trip
  if (!getIt.isRegistered<StartTripUseCase>()) {
    getIt.registerLazySingleton<StartTripUseCase>(
      () => StartTripUseCase(repository: getIt()),
    );
  }

  // Complete Trip
  if (!getIt.isRegistered<CompleteRideUseCase>()) {
    getIt.registerLazySingleton<CompleteRideUseCase>(
      () => CompleteRideUseCase(repository: getIt()),
    );
  }

  // ==========================================================
  // DRIVER - AVAILABILITY
  // ==========================================================

  if (!getIt.isRegistered<SetDriverAvailabilityUseCase>()) {
    getIt.registerLazySingleton<SetDriverAvailabilityUseCase>(
      () => SetDriverAvailabilityUseCase(repository: getIt()),
    );
  }

  // ==========================================================
  // DRIVER - LOCATION
  // ==========================================================

  if (!getIt.isRegistered<UpdateDriverLocationUseCase>()) {
    getIt.registerLazySingleton<UpdateDriverLocationUseCase>(
      () => UpdateDriverLocationUseCase(repository: getIt()),
    );
  }
}
