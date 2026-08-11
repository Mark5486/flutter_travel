// lib/core/services/device_service.dart
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';

abstract class DeviceService {
  Future<String> getDeviceUniqueId();
}

class DeviceServiceImpl implements DeviceService {
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  @override
  Future<String> getDeviceUniqueId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        // id يمثل المعرف الفريد للهاتف في الأندرويد وهو مستقر ومضمون
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        // identifierForVendor يمثل المعرف الفريد للمطور على الـ iOS
        return iosInfo.identifierForVendor ?? 'UNKNOWN_IOS_ID';
      }
      return 'UNKNOWN_PLATFORM_ID';
    } catch (_) {
      return 'ERROR_FETCHING_DEVICE_ID';
    }
  }
}
