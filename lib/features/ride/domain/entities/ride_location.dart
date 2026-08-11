import 'package:equatable/equatable.dart';

/// نقطة على الخريطة (لحظة الالتقاط أو الوجهة) بالإحداثيات + العنوان النصي
class RideLocation extends Equatable {
  final double lat;
  final double lng;
  final String address;

  const RideLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  @override
  List<Object?> get props => [lat, lng, address];
}
