import 'package:get_it/get_it.dart';

import '../services/location_service.dart';

final getIt = GetIt.instance;

void setupMapLocator() {
  if (!getIt.isRegistered<LocationService>()) {
    getIt.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  }
}
