import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

class AuthFooter extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onPressed;

  const AuthFooter({
    super.key,
    required this.title,
    required this.actionText,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(title),
        TextButton(
          onPressed: onPressed,
          child: Text(
            actionText,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
