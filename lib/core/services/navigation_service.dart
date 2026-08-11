import 'package:flutter/material.dart';

abstract class NavigationService {
  GlobalKey<NavigatorState> get navigatorKey;
  Future<dynamic>? navigateTo(String routeName, {Object? arguments});
  Future<dynamic>? navigateToAndReplace(String routeName, {Object? arguments});
  void goBack();
}

class NavigationServiceImpl implements NavigationService {
  @override
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Future<dynamic>? navigateTo(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushNamed(
      routeName,
      arguments: arguments,
    );
  }

  @override
  Future<dynamic>? navigateToAndReplace(String routeName, {Object? arguments}) {
    return navigatorKey.currentState?.pushReplacementNamed(
      routeName,
      arguments: arguments,
    );
  }

  @override
  void goBack() {
    navigatorKey.currentState?.pop();
  }
}
