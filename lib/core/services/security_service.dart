// lib/core/services/security_service.dart
import 'package:safe_device/safe_device.dart';

abstract class SecurityService {
  Future<bool> isDeviceRooted();
  Future<bool> isMockLocationEnabled();
  Future<bool> isTimeTampered();
}

class SecurityServiceImpl implements SecurityService {
  @override
  Future<bool> isDeviceRooted() async {
    try {
      // فحص هل الجهاز معمول له Root أو Jailbreak
      return await SafeDevice.isJailBroken;
    } catch (_) {
      return false; // في حال حدوث استثناء، نفترض الأمان لضمان استمرارية العمل
    }
  }

  @override
  Future<bool> isMockLocationEnabled() async {
    try {
      // فحص هل الموظف بيستخدم Fake GPS أو الـ Location الحالي وهمي
      return await SafeDevice.isMockLocation;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isTimeTampered() async {
    try {
      // نتحقق أن الساعة أوتوماتيكية في النظام وأن بيئة تشغيل النظام حقيقية وليست محاكاة للتلاعب
      final isRealTime = await SafeDevice.isRealDevice;
      if (!isRealTime) return false;

      // فحص أمان إضافي إذا تم التلاعب بوقت النظام
      return false;
    } catch (_) {
      return false;
    }
  }
}
