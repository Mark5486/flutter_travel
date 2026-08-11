import 'package:flutter_travel_10/core/di/auth_locator.dart';
import 'package:flutter_travel_10/core/di/core_locator.dart';
import 'package:flutter_travel_10/core/di/map_locator.dart';
import 'package:flutter_travel_10/core/di/notification_locator.dart';
import 'package:flutter_travel_10/core/di/ride_locator.dart';

/// ==========================================================
///
/// Dependency Injection Entry Point
///
/// استدعِ setupLocator() مرة واحدة فقط داخل main.dart
///
/// ==========================================================
Future<void> setupLocator() async {
  //==========================================================
  // Core
  //==========================================================

  await setupCoreLocator();

  //==========================================================
  // Features
  //==========================================================

  setupAuthLocator();

  setupMapLocator();

  setupRideLocator();

  setupNotificationLocator();
}
