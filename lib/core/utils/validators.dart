import '../constants/app_strings.dart';
import 'extensions.dart';

class Validators {
  static String? validateEmail(String? value) {
    final trimmedValue = value?.trim();

    if (trimmedValue == null || trimmedValue.isEmpty) {
      return AppStrings.emailRequired;
    }

    if (!trimmedValue.isValidEmail) {
      return AppStrings.invalidEmail;
    }

    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }

    if (!value.isValidPassword) {
      return AppStrings.passwordTooShort;
    }

    return null;
  }
}