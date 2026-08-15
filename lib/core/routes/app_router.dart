import 'package:flutter/material.dart';

import '../../features/auth/domain/entities/app_user.dart';
import '../../features/auth/presentation/screen/home_page.dart';
import '../../features/auth/presentation/screen/login_page.dart';
import '../../features/auth/presentation/screen/register_page.dart';
import '../../features/auth/presentation/screen/splash_page.dart';
import '../../features/ride/presentation/screen/Page/client_home_page.dart';
import '../../features/ride/presentation/screen/Page/driver_home_page.dart';
import '../constants/app_routes.dart';

class AppRouter {
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return MaterialPageRoute(
          builder: (_) => const SplashPage(),
          settings: settings,
        );

      case AppRoutes.login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );

      case AppRoutes.register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );

      case AppRoutes.home:
        return MaterialPageRoute(
          builder: (_) => const HomePage(),
          settings: settings,
        );

      case AppRoutes.clientHome:
        final user = settings.arguments as AppUser?;

        if (user == null) {
          return MaterialPageRoute(
            builder: (_) => const LoginPage(),
            settings: settings,
          );
        }

        return MaterialPageRoute(
          builder: (_) => ClientHomePage(client: user),
          settings: settings,
        );

      case AppRoutes.driverHome:
        final user = settings.arguments as AppUser?;

        if (user == null) {
          return MaterialPageRoute(
            builder: (_) => const LoginPage(),
            settings: settings,
          );
        }

        return MaterialPageRoute(
          builder: (_) => DriverHomePage(driver: user),
          settings: settings,
        );

      default:
        return MaterialPageRoute(
          builder:
              (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
          settings: settings,
        );
    }
  }
}
