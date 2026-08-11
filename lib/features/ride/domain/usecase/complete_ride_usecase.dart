import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_repository.dart';

class CompleteRideUseCase {
  final RideRepository repository;

  const CompleteRideUseCase({required this.repository});

  Future<Either<Failure, Unit>> call(String rideId) {
    return repository.completeRide(rideId);
  }
}
