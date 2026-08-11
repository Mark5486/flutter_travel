import '../../../../core/errors/failures.dart';
import 'package:dartz/dartz.dart';

import '../entities/ride.dart';
import '../repositories/ride_repository.dart';

class WatchRideUseCase {
  final RideRepository repository;

  const WatchRideUseCase({required this.repository});

  Stream<Either<Failure, Ride?>> call(String rideId) {
    return repository.watchRide(rideId);
  }
}
