import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride.dart';
import '../repositories/ride_repository.dart';

class WatchIncomingRequestsUseCase {
  final RideRepository repository;

  const WatchIncomingRequestsUseCase({required this.repository});

  Stream<Either<Failure, List<Ride>>> call(String driverId) {
    return repository.watchIncomingRequests(driverId);
  }
}
