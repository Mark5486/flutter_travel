import 'package:flutter_travel_10/core/di/auth_locator.dart';
import 'package:flutter_travel_10/core/di/core_locator.dart';
import 'package:flutter_travel_10/core/di/map_locator.dart';
import 'package:flutter_travel_10/core/di/ride_locator.dart';

Future<void> setupLocator() async {
  await setupCoreLocator();

  setupAuthLocator();

  setupMapLocator();

  setupRideLocator();
}
