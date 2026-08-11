import '../constants/app_strings.dart'; // استيراد ملف النصوص بتاعك
import 'extensions.dart'; // استيراد الإكستنشنز اللي أنت بانيها

class Validators {
  // التحقق من البريد الإلكتروني
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings
          .emailRequired; // استخدام الثوابت بدل النص المكتوب يدويًا
    }

    // سينيور تاتش: استخدام الإكستنشن مباشرة بدلاً من إعادة كتابة الـ Regex هنا
    if (!value.isValidEmail) {
      return AppStrings.invalidEmail;
    }

    return null;
  }

  // التحقق من كلمة المرور
  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return AppStrings.passwordRequired;
    }

    // سينيور تاتش: استخدام الإكستنشن اللي بتتحقق من الطول
    if (!value.isValidPassword) {
      return AppStrings.passwordTooShort;
    }

    return null;
  }
}
