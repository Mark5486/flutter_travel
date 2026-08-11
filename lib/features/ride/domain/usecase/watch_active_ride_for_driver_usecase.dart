import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride.dart';
import '../repositories/ride_repository.dart';

class WatchActiveRideForDriverUseCase {
  final RideRepository repository;

  const WatchActiveRideForDriverUseCase({required this.repository});

  Stream<Either<Failure, Ride?>> call(String driverId) {
    return repository.watchActiveRideForDriver(driverId);
  }
}
