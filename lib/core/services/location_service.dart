import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

import '../errors/exceptions.dart';

abstract class LocationService {
  /// بيتأكد إن صلاحية الموقع متاحة ومفعلة، ولو لأ بيرمي [LocationException]
  Future<void> ensurePermissionGranted();

  /// موقع الجهاز الحالي
  Future<Position> getCurrentPosition();

  /// استماع مستمر لتحديثات الموقع (بيتستخدم وقت ما السواق يبقى Online)
  Stream<Position> watchPosition();

  /// تحويل إحداثيات لعنوان نصي مقروء
  Future<String> getAddressFromCoordinates(double lat, double lng);

  /// تحويل عنوان نصي لإحداثيات (بحث عن مكان)
  Future<({double lat, double lng})?> getCoordinatesFromAddress(
    String address,
  );

  /// المسافة بين نقطتين بالكيلومتر
  double distanceInKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  });
}

class LocationServiceImpl implements LocationService {
  @override
  Future<void> ensurePermissionGranted() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      throw const LocationException(
        'خدمة تحديد الموقع غير مفعلة، من فضلك فعّلها من إعدادات الجهاز.',
      );
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        throw const LocationException('لازم تسمح للتطبيق بالوصول لموقعك.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'تم رفض صلاحية الموقع نهائيًا، من فضلك فعّلها يدويًا من إعدادات الجهاز.',
      );
    }
  }

  @override
  Future<Position> getCurrentPosition() async {
    await ensurePermissionGranted();

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  }

  @override
  Stream<Position> watchPosition() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 20,
      ),
    );
  }

  @override
  Future<String> getAddressFromCoordinates(double lat, double lng) async {
    try {
      final placemarks = await placemarkFromCoordinates(lat, lng);

      if (placemarks.isEmpty) return 'موقع غير معروف';

      final place = placemarks.first;

      final parts = [
        place.street,
        place.subLocality,
        place.locality,
      ].where((part) => part != null && part.trim().isNotEmpty).toList();

      return parts.isEmpty ? 'موقع غير معروف' : parts.join('، ');
    } catch (_) {
      return 'موقع غير معروف';
    }
  }

  @override
  Future<({double lat, double lng})?> getCoordinatesFromAddress(
    String address,
  ) async {
    try {
      final locations = await locationFromAddress(address);

      if (locations.isEmpty) return null;

      final location = locations.first;

      return (lat: location.latitude, lng: location.longitude);
    } catch (_) {
      return null;
    }
  }

  @override
  double distanceInKm({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
  }) {
    final meters = Geolocator.distanceBetween(
      startLat,
      startLng,
      endLat,
      endLng,
    );

    return meters / 1000;
  }
}
