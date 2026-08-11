import 'package:get_it/get_it.dart';

import '../services/location_service.dart';

final getIt = GetIt.instance;

/// ==========================================================
///
/// Maps Feature
///
/// ==========================================================
void setupMapLocator() {
  //==========================================================
  // Services
  //==========================================================

  if (!getIt.isRegistered<LocationService>()) {
    getIt.registerLazySingleton<LocationService>(() => LocationServiceImpl());
  }
}
