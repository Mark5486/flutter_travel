import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_repository.dart';

class CancelRideUseCase {
  final RideRepository repository;

  const CancelRideUseCase({required this.repository});

  Future<Either<Failure, Unit>> call(String rideId) {
    return repository.cancelRide(rideId);
  }
}
