import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_travel_10/firebase_options.dart';

import 'core/constants/app_routes.dart';
import 'core/di/core_locator.dart';
import 'core/services/navigation_service.dart';
import 'core/theme/cubit/theme_cubit.dart';
import 'core/theme/dark_theme.dart';
import 'core/theme/light_theme.dart';
import 'core/utils/service_locator.dart';

import 'features/auth/presentation/screen/home_page.dart';
import 'features/auth/presentation/screen/login_page.dart';
import 'features/auth/presentation/screen/register_page.dart';
import 'features/auth/presentation/screen/splash_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize GetIt
  await setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ThemeCubit>(
      create: (_) => getIt<ThemeCubit>(),
      child: BlocBuilder<ThemeCubit, ThemeMode>(
        builder: (context, themeMode) {
          return MaterialApp(
            title: 'تطبيق الرحلات',
            debugShowCheckedModeBanner: false,

            // Navigation
            navigatorKey: getIt<NavigationService>().navigatorKey,

            // Theme
            theme: LightTheme.theme,
            darkTheme: DarkTheme.theme,
            themeMode: themeMode,

            // First screen
            initialRoute: AppRoutes.splash,

            // Routes
            routes: {
              AppRoutes.splash: (_) => const SplashPage(),
              AppRoutes.login: (_) => const LoginPage(),
              AppRoutes.register: (_) => const RegisterPage(),
              AppRoutes.home: (_) => const HomePage(),
            },
          );
        },
      ),
    );
  }
}
