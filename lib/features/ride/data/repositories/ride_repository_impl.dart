import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/firebase_error_handler.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_location.dart';
import '../../domain/repositories/ride_repository.dart';
import '../datasources/ride_remote_data_source.dart';

class RideRepositoryImpl with FirebaseErrorHandler implements RideRepository {
  final RideRemoteDataSource remoteDataSource;

  const RideRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, Ride>> requestRide({
    required String riderId,
    required String riderName,
    required String riderPhone,
    required RideLocation pickup,
    required RideLocation destination,
    required double distanceKm,
    required double estimatedFare,
  }) {
    return executeSafely(
      () => remoteDataSource.requestRide(
        riderId: riderId,
        riderName: riderName,
        riderPhone: riderPhone,
        pickup: pickup,
        destination: destination,
        distanceKm: distanceKm,
        estimatedFare: estimatedFare,
      ),
    );
  }

  @override
  Stream<Either<Failure, Ride?>> watchRide(String rideId) {
    return _wrapStream(remoteDataSource.watchRide(rideId));
  }

  @override
  Stream<Either<Failure, List<Ride>>> watchIncomingRequests(String driverId) {
    return _wrapStream(remoteDataSource.watchIncomingRequests(driverId));
  }

  @override
  Stream<Either<Failure, Ride?>> watchActiveRideForDriver(String driverId) {
    return _wrapStream(remoteDataSource.watchActiveRideForDriver(driverId));
  }

  @override
  Future<Either<Failure, Unit>> acceptRide({
    required String rideId,
    required String driverId,
    required String driverName,
    required String driverPhone,
  }) {
    return executeSafely(() async {
      await remoteDataSource.acceptRide(
        rideId: rideId,
        driverId: driverId,
        driverName: driverName,
        driverPhone: driverPhone,
      );
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> rejectRide({
    required String rideId,
    required String driverId,
  }) {
    return executeSafely(() async {
      await remoteDataSource.rejectRide(rideId: rideId, driverId: driverId);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> driverArrived(String rideId) {
    return executeSafely(() async {
      await remoteDataSource.driverArrived(rideId);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> startTrip(String rideId) {
    return executeSafely(() async {
      await remoteDataSource.startTrip(rideId);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> completeRide(String rideId) {
    return executeSafely(() async {
      await remoteDataSource.completeRide(rideId);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> cancelRide(String rideId) {
    return executeSafely(() async {
      await remoteDataSource.cancelRide(rideId);
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> setDriverAvailability({
    required String driverId,
    required String driverName,
    required bool isOnline,
    double? lat,
    double? lng,
  }) {
    return executeSafely(() async {
      await remoteDataSource.setDriverAvailability(
        driverId: driverId,
        driverName: driverName,
        isOnline: isOnline,
        lat: lat,
        lng: lng,
      );
      return unit;
    });
  }

  @override
  Future<Either<Failure, Unit>> updateDriverLocation({
    required String driverId,
    required double lat,
    required double lng,
  }) {
    return executeSafely(() async {
      await remoteDataSource.updateDriverLocation(
        driverId: driverId,
        lat: lat,
        lng: lng,
      );
      return unit;
    });
  }

  Stream<Either<Failure, T>> _wrapStream<T>(Stream<T> source) async* {
    try {
      await for (final value in source) {
        yield Right(value);
      }
    } on AuthException catch (e) {
      yield Left(ServerFailure(e.message));
    } on ServerException catch (e) {
      yield Left(ServerFailure(e.message));
    } on FirebaseException catch (e) {
      yield Left(
        ServerFailure(e.message ?? 'حدث خطأ أثناء الاتصال بقاعدة البيانات.'),
      );
    } catch (_) {
      yield const Left(ServerFailure('حدث خطأ غير متوقع.'));
    }
  }
}
