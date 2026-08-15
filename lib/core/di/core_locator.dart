import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/biometric_service.dart';
import '../services/device_service.dart';
import '../services/firebase_service.dart';
import '../services/local_storage_service.dart';
import '../services/security_service.dart';

final getIt = GetIt.instance;

Future<void> setupCoreLocator() async {
  final prefs = await SharedPreferences.getInstance();

  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(prefs);
  }

  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }

  if (!getIt.isRegistered<LocalStorageService>()) {
    getIt.registerLazySingleton<LocalStorageService>(
      () => LocalStorageService(preferences: getIt<SharedPreferences>()),
    );
  }

  if (!getIt.isRegistered<FirebaseService>()) {
    getIt.registerLazySingleton<FirebaseService>(
      () => FirebaseServiceImpl(
        auth: getIt<FirebaseAuth>(),
        firestore: getIt<FirebaseFirestore>(),
      ),
    );
  }

  if (!getIt.isRegistered<BiometricService>()) {
    getIt.registerLazySingleton<BiometricService>(() => BiometricServiceImpl());
  }

  if (!getIt.isRegistered<DeviceService>()) {
    getIt.registerLazySingleton<DeviceService>(() => DeviceServiceImpl());
  }

  if (!getIt.isRegistered<SecurityService>()) {
    getIt.registerLazySingleton<SecurityService>(() => SecurityServiceImpl());
  }
}
