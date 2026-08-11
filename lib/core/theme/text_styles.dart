import 'package:flutter/material.dart';
import '../constants/app_sizes.dart';

class AppTextStyles {
  static const TextStyle headlineLarge = TextStyle(
    fontSize: AppSizes.fontSizeXLarge,
    fontWeight: FontWeight.bold,
    height: 1.3,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: AppSizes.fontSizeLarge,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const TextStyle bodyLarge = TextStyle(
    fontSize: AppSizes.fontSizeMedium,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: AppSizes.fontSizeSmall,
    fontWeight: FontWeight.normal,
    height: 1.5,
  );

  static const TextStyle buttonLarge = TextStyle(
    fontSize: AppSizes.fontSizeMedium,
    fontWeight: FontWeight.bold,
    letterSpacing: 0.5,
  );

  static const TextStyle caption = TextStyle(
    fontSize: AppSizes.fontSizeXSmall,
    fontWeight: FontWeight.normal,
    height: 1.2,
    color: Colors.grey,
  );
}
