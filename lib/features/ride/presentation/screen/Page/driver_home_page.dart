import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_travel_10/core/di/auth_locator.dart' as ride_di;
import 'package:flutter_travel_10/features/auth/domain/entities/app_user.dart';
import 'package:flutter_travel_10/features/ride/presentation/cubit/driver_home_cubit.dart';
import 'package:flutter_travel_10/features/ride/presentation/screen/view/driver_home_page.dart';

class DriverHomePage extends StatelessWidget {
  final AppUser driver;

  const DriverHomePage({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ride_di.getIt<DriverHomeCubit>(param1: driver),
      child: const DriverHomeView(),
    );
  }
}
