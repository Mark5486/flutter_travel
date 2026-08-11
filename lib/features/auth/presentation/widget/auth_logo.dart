import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AuthLogo extends StatelessWidget {
  const AuthLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return const CircleAvatar(
      radius: 55,
      backgroundColor: AppColors.primary,
      child: Icon(Icons.local_taxi_rounded, size: 60, color: Colors.white),
    );
  }
}
