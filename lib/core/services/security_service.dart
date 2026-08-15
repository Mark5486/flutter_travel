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
      return await SafeDevice.isJailBroken;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isMockLocationEnabled() async {
    try {
      return await SafeDevice.isMockLocation;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool> isTimeTampered() async {
    try {
      final isRealTime = await SafeDevice.isRealDevice;
      if (!isRealTime) return false;

      return false;
    } catch (_) {
      return false;
    }
  }
}
