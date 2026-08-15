import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_travel_10/core/di/auth_locator.dart' as ride_di;
import 'package:flutter_travel_10/features/auth/domain/entities/app_user.dart';
import 'package:flutter_travel_10/features/ride/presentation/cubit/client_home_cubit.dart';
import 'package:flutter_travel_10/features/ride/presentation/screen/view/client_home_page.dart';

class ClientHomePage extends StatelessWidget {
  final AppUser client;

  const ClientHomePage({super.key, required this.client});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) =>
              ride_di.getIt<ClientHomeCubit>(param1: client)
                ..loadCurrentLocation(),
      child: const ClientHomeView(),
    );
  }
}
