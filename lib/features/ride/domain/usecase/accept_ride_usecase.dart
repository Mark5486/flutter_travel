import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_repository.dart';

class AcceptRideUseCase {
  final RideRepository repository;

  const AcceptRideUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({
    required String rideId,
    required String driverId,
    required String driverName,
    required String driverPhone,
  }) {
    return repository.acceptRide(
      rideId: rideId,
      driverId: driverId,
      driverName: driverName,
      driverPhone: driverPhone,
    );
  }
}
