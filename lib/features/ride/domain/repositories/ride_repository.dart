import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/ride.dart';
import '../entities/ride_location.dart';

abstract class RideRepository {
  Future<Either<Failure, Ride>> requestRide({
    required String riderId,
    required String riderName,
    required String riderPhone,
    required RideLocation pickup,
    required RideLocation destination,
    required double distanceKm,
    required double estimatedFare,
  });

  Stream<Either<Failure, Ride?>> watchRide(String rideId);

  Stream<Either<Failure, List<Ride>>> watchIncomingRequests(String driverId);

  Stream<Either<Failure, Ride?>> watchActiveRideForDriver(String driverId);

  Future<Either<Failure, Unit>> acceptRide({
    required String rideId,
    required String driverId,
    required String driverName,
    required String driverPhone,
  });

  Future<Either<Failure, Unit>> rejectRide({
    required String rideId,
    required String driverId,
  });

  Future<Either<Failure, Unit>> driverArrived(String rideId);

  Future<Either<Failure, Unit>> startTrip(String rideId);

  Future<Either<Failure, Unit>> completeRide(String rideId);

  Future<Either<Failure, Unit>> cancelRide(String rideId);

  Future<Either<Failure, Unit>> setDriverAvailability({
    required String driverId,
    required String driverName,
    required bool isOnline,
    double? lat,
    double? lng,
  });

  Future<Either<Failure, Unit>> updateDriverLocation({
    required String driverId,
    required double lat,
    required double lng,
  });
}
