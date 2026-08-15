import 'package:get_it/get_it.dart';

import '../../features/auth/domain/entities/app_user.dart';
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
import '../../features/ride/presentation/cubit/client_home_cubit.dart';
import '../../features/ride/presentation/cubit/driver_home_cubit.dart';

final getIt = GetIt.instance;

void setupRideLocator() {
  if (!getIt.isRegistered<RideRemoteDataSource>()) {
    getIt.registerLazySingleton<RideRemoteDataSource>(
      () => RideRemoteDataSourceImpl(firebaseService: getIt()),
    );
  }

  if (!getIt.isRegistered<RideRepository>()) {
    getIt.registerLazySingleton<RideRepository>(
      () => RideRepositoryImpl(remoteDataSource: getIt()),
    );
  }

  if (!getIt.isRegistered<RequestRideUseCase>()) {
    getIt.registerLazySingleton<RequestRideUseCase>(
      () => RequestRideUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<WatchRideUseCase>()) {
    getIt.registerLazySingleton<WatchRideUseCase>(
      () => WatchRideUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<CancelRideUseCase>()) {
    getIt.registerLazySingleton<CancelRideUseCase>(
      () => CancelRideUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<WatchIncomingRequestsUseCase>()) {
    getIt.registerLazySingleton<WatchIncomingRequestsUseCase>(
      () => WatchIncomingRequestsUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<WatchActiveRideForDriverUseCase>()) {
    getIt.registerLazySingleton<WatchActiveRideForDriverUseCase>(
      () => WatchActiveRideForDriverUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<AcceptRideUseCase>()) {
    getIt.registerLazySingleton<AcceptRideUseCase>(
      () => AcceptRideUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<RejectRideUseCase>()) {
    getIt.registerLazySingleton<RejectRideUseCase>(
      () => RejectRideUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<DriverArrivedUseCase>()) {
    getIt.registerLazySingleton<DriverArrivedUseCase>(
      () => DriverArrivedUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<StartTripUseCase>()) {
    getIt.registerLazySingleton<StartTripUseCase>(
      () => StartTripUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<CompleteRideUseCase>()) {
    getIt.registerLazySingleton<CompleteRideUseCase>(
      () => CompleteRideUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<SetDriverAvailabilityUseCase>()) {
    getIt.registerLazySingleton<SetDriverAvailabilityUseCase>(
      () => SetDriverAvailabilityUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<UpdateDriverLocationUseCase>()) {
    getIt.registerLazySingleton<UpdateDriverLocationUseCase>(
      () => UpdateDriverLocationUseCase(repository: getIt()),
    );
  }

  if (!getIt.isRegistered<DriverHomeCubit>()) {
    getIt.registerFactoryParam<DriverHomeCubit, AppUser, void>(
      (driver, _) => DriverHomeCubit(
        driverId: driver.uid,
        driverName: driver.name,
        driverPhone: driver.phone,
        locationService: getIt(),
        setDriverAvailabilityUseCase: getIt(),
        updateDriverLocationUseCase: getIt(),
        watchIncomingRequestsUseCase: getIt(),
        watchActiveRideForDriverUseCase: getIt(),
        acceptRideUseCase: getIt(),
        rejectRideUseCase: getIt(),
        driverArrivedUseCase: getIt(),
        startTripUseCase: getIt(),
        completeRideUseCase: getIt(),
      ),
    );
  }

  if (!getIt.isRegistered<ClientHomeCubit>()) {
    getIt.registerFactoryParam<ClientHomeCubit, AppUser, void>(
      (client, _) => ClientHomeCubit(
        riderId: client.uid,
        riderName: client.name,
        riderPhone: client.phone,
        locationService: getIt(),
        requestRideUseCase: getIt(),
        watchRideUseCase: getIt(),
        cancelRideUseCase: getIt(),
      ),
    );
  }
}
