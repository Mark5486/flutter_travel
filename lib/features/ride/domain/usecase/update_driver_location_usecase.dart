import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/ride_repository.dart';

class UpdateDriverLocationUseCase {
  final RideRepository repository;

  const UpdateDriverLocationUseCase({required this.repository});

  Future<Either<Failure, Unit>> call({
    required String driverId,
    required double lat,
    required double lng,
  }) {
    return repository.updateDriverLocation(
      driverId: driverId,
      lat: lat,
      lng: lng,
    );
  }
}
