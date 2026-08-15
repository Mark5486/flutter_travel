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
        return androidInfo.id;
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return iosInfo.identifierForVendor ?? 'UNKNOWN_IOS_ID';
      }
      return 'UNKNOWN_PLATFORM_ID';
    } catch (_) {
      return 'ERROR_FETCHING_DEVICE_ID';
    }
  }
}
