import 'dart:io';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import '../errors/exceptions.dart';

abstract class LocationService {
  Future<void> ensurePermissionGranted();
  Future<Position> getCurrentPosition();
  Stream<Position> watchPosition();
  Future<String> getAddressFromCoordinates(double lat, double lng);
  Future<({double lat, double lng})?> getCoordinatesFromAddress(String address);
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
    late LocationSettings locationSettings;

    if (Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15, // تحديث كل 15 متر لتقليل استهلاك البطارية والـ Firebase
        forceLocationManager: true,
        intervalDuration: const Duration(seconds: 5),
      );
    } else if (Platform.isIOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.high,
        activityType: ActivityType.automotiveNavigation, // تحسين الدقة للسائقين
        distanceFilter: 15,
        pauseLocationUpdatesAutomatically: false,
        showBackgroundLocationIndicator: true,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 15,
      );
    }

    return Geolocator.getPositionStream(locationSettings: locationSettings);
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