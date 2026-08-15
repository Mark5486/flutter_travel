import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_travel_10/core/routes/app_router.dart';
import 'package:flutter_travel_10/firebase_options.dart';

import 'core/constants/app_routes.dart';
import 'core/di/core_locator.dart';
import 'core/utils/service_locator.dart';

import 'features/auth/presentation/cubit/auth_cubit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await setupLocator();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>(),
      child: MaterialApp(
        title: 'تطبيق الرحلات',
        debugShowCheckedModeBanner: false,

        initialRoute: AppRoutes.splash,

        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
