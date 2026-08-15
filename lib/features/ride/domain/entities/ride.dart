import 'package:equatable/equatable.dart';
import 'package:flutter_travel_10/features/ride/domain/entities/ride_location.dart';
import 'package:flutter_travel_10/features/ride/domain/entities/ride_status.dart';

class Ride extends Equatable {
  final String id;

  final String riderId;
  final String riderName;
  final String riderPhone;

  final String? driverId;
  final String? driverName;
  final String? driverPhone;

  final RideLocation pickup;
  final RideLocation destination;

  final RideLocation? driverLocation;

  final double distanceKm;
  final double estimatedFare;

  final RideStatus status;

  final List<String> rejectedDriverIds;

  final DateTime? createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;

  const Ride({
    required this.id,
    required this.riderId,
    required this.riderName,
    required this.riderPhone,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.pickup,
    required this.destination,
    this.driverLocation,
    required this.distanceKm,
    required this.estimatedFare,
    required this.status,
    this.rejectedDriverIds = const [],
    this.createdAt,
    this.acceptedAt,
    this.completedAt,
  });

  Ride copyWith({
    String? id,
    String? riderId,
    String? riderName,
    String? riderPhone,
    String? driverId,
    String? driverName,
    String? driverPhone,
    RideLocation? pickup,
    RideLocation? destination,
    RideLocation? driverLocation,
    double? distanceKm,
    double? estimatedFare,
    RideStatus? status,
    List<String>? rejectedDriverIds,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
  }) {
    return Ride(
      id: id ?? this.id,
      riderId: riderId ?? this.riderId,
      riderName: riderName ?? this.riderName,
      riderPhone: riderPhone ?? this.riderPhone,
      driverId: driverId ?? this.driverId,
      driverName: driverName ?? this.driverName,
      driverPhone: driverPhone ?? this.driverPhone,
      pickup: pickup ?? this.pickup,
      destination: destination ?? this.destination,
      driverLocation: driverLocation ?? this.driverLocation,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedFare: estimatedFare ?? this.estimatedFare,
      status: status ?? this.status,
      rejectedDriverIds:
          rejectedDriverIds ?? List.unmodifiable(this.rejectedDriverIds),
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    riderId,
    riderName,
    riderPhone,
    driverId,
    driverName,
    driverPhone,
    pickup,
    destination,
    driverLocation,
    distanceKm,
    estimatedFare,
    status,
    rejectedDriverIds,
    createdAt,
    acceptedAt,
    completedAt,
  ];
}
