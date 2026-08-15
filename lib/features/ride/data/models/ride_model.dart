import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_location.dart';
import '../../domain/entities/ride_status.dart';

class RideModel extends Ride {
  const RideModel({
    required super.id,
    required super.riderId,
    required super.riderName,
    required super.riderPhone,
    super.driverId,
    super.driverName,
    super.driverPhone,
    required super.pickup,
    required super.destination,
    super.driverLocation,
    required super.distanceKm,
    required super.estimatedFare,
    required super.status,
    super.rejectedDriverIds,
    super.createdAt,
    super.acceptedAt,
    super.completedAt,
  });

  factory RideModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw Exception('بيانات الرحلة غير موجودة.');
    }

    final pickupData = Map<String, dynamic>.from(
      data['pickup'] ?? <String, dynamic>{},
    );

    final destinationData = Map<String, dynamic>.from(
      data['destination'] ?? <String, dynamic>{},
    );

    final driverLocationData =
        data['driverLocation'] != null
            ? Map<String, dynamic>.from(data['driverLocation'])
            : null;

    return RideModel(
      id: document.id,
      riderId: data['riderId'] as String? ?? '',
      riderName: data['riderName'] as String? ?? '',
      riderPhone: data['riderPhone'] as String? ?? '',
      driverId: data['driverId'] as String?,
      driverName: data['driverName'] as String?,
      driverPhone: data['driverPhone'] as String?,
      pickup: RideLocation.fromMap(pickupData),
      destination: RideLocation.fromMap(destinationData),
      driverLocation:
          driverLocationData != null
              ? RideLocation.fromMap(driverLocationData)
              : null,
      distanceKm: (data['distanceKm'] as num?)?.toDouble() ?? 0.0,
      estimatedFare: (data['estimatedFare'] as num?)?.toDouble() ?? 0.0,
      status: RideStatus.fromValue(data['status'] as String?),
      rejectedDriverIds: List<String>.from(
        data['rejectedDriverIds'] ?? const [],
      ),
      createdAt: _timestampToDate(data['createdAt']),
      acceptedAt: _timestampToDate(data['acceptedAt']),
      completedAt: _timestampToDate(data['completedAt']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'riderId': riderId,
      'riderName': riderName,
      'riderPhone': riderPhone,
      'driverId': driverId,
      'driverName': driverName,
      'driverPhone': driverPhone,
      'pickup': pickup.toMap(),
      'destination': destination.toMap(),
      'driverLocation': driverLocation?.toMap(),
      'distanceKm': distanceKm,
      'estimatedFare': estimatedFare,
      'status': status.value,
      'rejectedDriverIds': rejectedDriverIds,
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt':
          completedAt != null ? Timestamp.fromDate(completedAt!) : null,
    };
  }

  static DateTime? _timestampToDate(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    }
    if (value is DateTime) {
      return value;
    }
    return null;
  }
}
