// lib/core/services/biometric_service.dart
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';

abstract class BiometricService {
  Future<bool> isBiometricAvailable();
  Future<bool> authenticateUser({required String reason});
}

class BiometricServiceImpl implements BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  @override
  Future<bool> isBiometricAvailable() async {
    try {
      // التحقق هل الجهاز يدعم بصمة/وجه وهل المستخدم مفعلها في إعدادات موبايله
      final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
      final bool hasBiometrics = await _auth.isDeviceSupported();
      return canAuthenticateWithBiometrics && hasBiometrics;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> authenticateUser({required String reason}) async {
    try {
      // استدعاء التحقق المباشر بالاعتماد على رسالة النظام الافتراضية والـ localizedReason فقط
      return await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true, // تمنع قفل التطبيق لو الموظف خرج ورجع بسرعة
          biometricOnly:
              true, // إجبار استخدام البصمة/الوجه فقط ومنع الـ PIN أو رمز الشاشة
        ),
      );
    } on PlatformException catch (_) {
      return false; // في حال حدوث خطأ من نظام التشغيل
    }
  }
}
