import 'package:equatable/equatable.dart';

class RideLocation extends Equatable {
  final double lat;
  final double lng;
  final String address;

  const RideLocation({
    required this.lat,
    required this.lng,
    required this.address,
  });

  RideLocation copyWith({double? lat, double? lng, String? address}) {
    return RideLocation(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
    );
  }

  Map<String, dynamic> toMap() {
    return {'lat': lat, 'lng': lng, 'address': address};
  }

  factory RideLocation.fromMap(Map<String, dynamic> map) {
    return RideLocation(
      lat: (map['lat'] as num?)?.toDouble() ?? 0.0,
      lng: (map['lng'] as num?)?.toDouble() ?? 0.0,
      address: map['address'] as String? ?? '',
    );
  }

  @override
  List<Object?> get props => [lat, lng, address];
}
