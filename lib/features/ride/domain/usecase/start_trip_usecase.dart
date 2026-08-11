import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_repository.dart';

class StartTripUseCase {
  final RideRepository repository;

  const StartTripUseCase({required this.repository});

  Future<Either<Failure, Unit>> call(String rideId) {
    return repository.startTrip(rideId);
  }
}
