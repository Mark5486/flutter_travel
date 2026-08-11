import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../services/biometric_service.dart';
import '../services/device_service.dart';
import '../services/firebase_service.dart';
import '../services/navigation_service.dart';
import '../services/security_service.dart';
import '../theme/cubit/theme_cubit.dart';
import '../utils/data_helper.dart';

final getIt = GetIt.instance;

Future<void> setupCoreLocator() async {
  //==========================================================
  // Shared Preferences
  //==========================================================

  final prefs = await SharedPreferences.getInstance();

  if (!getIt.isRegistered<SharedPreferences>()) {
    getIt.registerSingleton<SharedPreferences>(prefs);
  }

  //==========================================================
  // Firebase
  //==========================================================

  if (!getIt.isRegistered<FirebaseAuth>()) {
    getIt.registerLazySingleton<FirebaseAuth>(() => FirebaseAuth.instance);
  }

  if (!getIt.isRegistered<FirebaseFirestore>()) {
    getIt.registerLazySingleton<FirebaseFirestore>(
      () => FirebaseFirestore.instance,
    );
  }

  //==========================================================
  // Helpers
  //==========================================================

  if (!getIt.isRegistered<DataHelper>()) {
    getIt.registerLazySingleton<DataHelper>(
      () => SharedPreferencesHelper(getIt<SharedPreferences>()),
    );
  }

  //==========================================================
  // Services
  //==========================================================

  if (!getIt.isRegistered<NavigationService>()) {
    getIt.registerLazySingleton<NavigationService>(
      () => NavigationServiceImpl(),
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

  //==========================================================
  // Theme
  //==========================================================

  if (!getIt.isRegistered<ThemeCubit>()) {
    getIt.registerLazySingleton<ThemeCubit>(
      () => ThemeCubit(dataHelper: getIt<DataHelper>()),
    );
  }
}
