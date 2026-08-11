import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_repository.dart';

class DriverArrivedUseCase {
  final RideRepository repository;

  const DriverArrivedUseCase({required this.repository});

  Future<Either<Failure, Unit>> call(String rideId) {
    return repository.driverArrived(rideId);
  }
}
