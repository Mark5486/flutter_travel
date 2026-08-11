import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_repository.dart';

class RejectRideUseCase {
  final RideRepository repository;

  const RejectRideUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({
    required String rideId,
    required String driverId,
  }) {
    return repository.rejectRide(rideId: rideId, driverId: driverId);
  }
}
