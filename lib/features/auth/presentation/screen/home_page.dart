import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/app_routes.dart';
import '../../../../core/di/core_locator.dart';
import '../../../../core/services/location_service.dart';

import '../../../ride/domain/usecase/cancel_ride_usecase.dart';
import '../../../ride/domain/usecase/request_ride_usecase.dart';
import '../../../ride/domain/usecase/watch_ride_usecase.dart';

import '../../../ride/presentation/cubit/client_home_cubit.dart';
import '../../../ride/presentation/screen/client_home_page.dart';
import '../../../ride/presentation/screen/driver_home_page.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AuthCubit>(
      create: (_) => getIt<AuthCubit>()..getCurrentUser(),
      child: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          }
        },
        builder: (context, state) {
          final user = state.user;

          // --------------------------------------------------
          // Loading
          // --------------------------------------------------

          if (user == null) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          // --------------------------------------------------
          // DRIVER
          // --------------------------------------------------

          if (user.role == 'driver') {
            return DriverHomePage(driver: user);
          }

          // --------------------------------------------------
          // CLIENT
          // --------------------------------------------------

          return BlocProvider<ClientHomeCubit>(
            create:
                (_) => ClientHomeCubit(
                  riderId: user.uid,
                  riderName: user.name,
                  riderPhone: user.phone,
                  locationService: getIt<LocationService>(),
                  requestRideUseCase: getIt<RequestRideUseCase>(),
                  watchRideUseCase: getIt<WatchRideUseCase>(),
                  cancelRideUseCase: getIt<CancelRideUseCase>(),
                )..loadCurrentLocation(),
            child: ClientHomePage(rider: user),
          );
        },
      ),
    );
  }
}
