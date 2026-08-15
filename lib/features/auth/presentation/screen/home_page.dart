import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/di/auth_locator.dart';
import '../../../ride/presentation/cubit/client_home_cubit.dart';
import '../../../ride/presentation/screen/Page/client_home_page.dart';
import '../../../ride/presentation/screen/Page/driver_home_page.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.unauthenticated) {
          Navigator.pushNamedAndRemoveUntil(
            context,
            AppRoutes.login,
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        if (state.status == AuthStatus.loading ||
            state.status == AuthStatus.initial) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state.status == AuthStatus.failure) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('حدث خطأ أثناء تحميل بيانات المستخدم'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<AuthCubit>().getCurrentUser();
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            ),
          );
        }

        final user = state.user;

        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (user.role == 'driver') {
          return DriverHomePage(driver: user);
        }

        return BlocProvider<ClientHomeCubit>(
          create:
              (_) =>
                  getIt<ClientHomeCubit>(param1: user)..loadCurrentLocation(),
          child: ClientHomePage(client: user),
        );
      },
    );
  }
}
