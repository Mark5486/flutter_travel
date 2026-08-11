import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_repository.dart';

class SetDriverAvailabilityUseCase {
  final RideRepository repository;

  const SetDriverAvailabilityUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({
    required String driverId,
    required String driverName,
    required bool isOnline,
    double? lat,
    double? lng,
  }) {
    return repository.setDriverAvailability(
      driverId: driverId,
      driverName: driverName,
      isOnline: isOnline,
      lat: lat,
      lng: lng,
    );
  }
}
