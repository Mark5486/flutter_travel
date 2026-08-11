import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride.dart';
import '../entities/ride_location.dart';
import '../repositories/ride_repository.dart';

class RequestRideUseCase {
  final RideRepository repository;

  const RequestRideUseCase({required this.repository});

  Future<Either<Failure, Ride>> call({
    required String riderId,
    required String riderName,
    required String riderPhone,
    required RideLocation pickup,
    required RideLocation destination,
    required double distanceKm,
    required double estimatedFare,
  }) {
    return repository.requestRide(
      riderId: riderId,
      riderName: riderName,
      riderPhone: riderPhone,
      pickup: pickup,
      destination: destination,
      distanceKm: distanceKm,
      estimatedFare: estimatedFare,
    );
  }
}
