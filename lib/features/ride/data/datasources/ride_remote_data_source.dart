import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/services/firebase_service.dart';
import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_location.dart';
import '../../domain/entities/ride_status.dart';
import '../models/ride_model.dart';

abstract class RideRemoteDataSource {
  Future<Ride> requestRide({
    required String riderId,
    required String riderName,
    required String riderPhone,
    required RideLocation pickup,
    required RideLocation destination,
    required double distanceKm,
    required double estimatedFare,
  });

  Stream<Ride?> watchRide(String rideId);

  Stream<List<Ride>> watchIncomingRequests(String driverId);

  Stream<Ride?> watchActiveRideForDriver(String driverId);

  Future<void> acceptRide({
    required String rideId,
    required String driverId,
    required String driverName,
    required String driverPhone,
  });

  Future<void> rejectRide({required String rideId, required String driverId});

  Future<void> driverArrived(String rideId);

  Future<void> startTrip(String rideId);

  Future<void> completeRide(String rideId);

  Future<void> cancelRide(String rideId);

  Future<void> setDriverAvailability({
    required String driverId,
    required String driverName,
    required bool isOnline,
    double? lat,
    double? lng,
  });

  Future<void> updateDriverLocation({
    required String driverId,
    required double lat,
    required double lng,
  });
}

class RideRemoteDataSourceImpl implements RideRemoteDataSource {
  final FirebaseService firebaseService;

  const RideRemoteDataSourceImpl({required this.firebaseService});

  CollectionReference<Map<String, dynamic>> get _rides =>
      firebaseService.collection(FirestoreCollections.rides);

  CollectionReference<Map<String, dynamic>> get _drivers =>
      firebaseService.collection(FirestoreCollections.drivers);

  @override
  Future<Ride> requestRide({
    required String riderId,
    required String riderName,
    required String riderPhone,
    required RideLocation pickup,
    required RideLocation destination,
    required double distanceKm,
    required double estimatedFare,
  }) async {
    final model = RideModel(
      id: '',
      riderId: riderId,
      riderName: riderName,
      riderPhone: riderPhone,
      pickup: pickup,
      destination: destination,
      distanceKm: distanceKm,
      estimatedFare: estimatedFare,
      status: RideStatus.pending,
    );

    final docRef = await _rides.add(model.toFirestore());

    final snapshot = await docRef.get();

    return RideModel.fromFirestore(snapshot);
  }

  @override
  Stream<Ride?> watchRide(String rideId) async* {
    await for (final snapshot in _rides.doc(rideId).snapshots()) {
      if (!snapshot.exists) {
        yield null;
        continue;
      }

      final ride = RideModel.fromFirestore(snapshot);

      if (ride.driverId == null) {
        yield ride;
        continue;
      }

      final driverSnapshot = await _drivers.doc(ride.driverId).get();

      if (!driverSnapshot.exists) {
        yield ride;
        continue;
      }

      final driverData = driverSnapshot.data();

      final lat = (driverData?['lat'] as num?)?.toDouble();
      final lng = (driverData?['lng'] as num?)?.toDouble();

      if (lat == null || lng == null) {
        yield ride;
        continue;
      }

      yield RideModel(
        id: ride.id,
        riderId: ride.riderId,
        riderName: ride.riderName,
        riderPhone: ride.riderPhone,
        driverId: ride.driverId,
        driverName: ride.driverName,
        driverPhone: ride.driverPhone,
        pickup: ride.pickup,
        destination: ride.destination,
        driverLocation: RideLocation(lat: lat, lng: lng, address: ''),
        distanceKm: ride.distanceKm,
        estimatedFare: ride.estimatedFare,
        status: ride.status,
        rejectedDriverIds: ride.rejectedDriverIds,
        createdAt: ride.createdAt,
        acceptedAt: ride.acceptedAt,
        completedAt: ride.completedAt,
      );
    }
  }

  @override
  Stream<List<Ride>> watchIncomingRequests(String driverId) {
    return _rides
        .where('status', isEqualTo: RideStatus.pending.value)
        .snapshots()
        .map((snapshot) {
          final rides =
              snapshot.docs
                  .map(RideModel.fromFirestore)
                  .where((ride) => !ride.rejectedDriverIds.contains(driverId))
                  .toList();

          rides.sort((a, b) {
            final aTime = a.createdAt ?? DateTime.now();
            final bTime = b.createdAt ?? DateTime.now();

            return aTime.compareTo(bTime);
          });

          return rides;
        });
  }

  @override
  Stream<RideModel?> watchActiveRideForDriver(String driverId) {
    const activeStatuses = [
      RideStatus.accepted,
      RideStatus.arrived,
      RideStatus.onTrip,
    ];

    return _rides.where('driverId', isEqualTo: driverId).snapshots().map((
      snapshot,
    ) {
      final rides =
          snapshot.docs
              .map(RideModel.fromFirestore)
              .where((ride) => activeStatuses.contains(ride.status))
              .toList();

      if (rides.isEmpty) {
        return null;
      }

      rides.sort((a, b) {
        final aTime = a.acceptedAt ?? DateTime.now();
        final bTime = b.acceptedAt ?? DateTime.now();

        return aTime.compareTo(bTime);
      });

      return rides.first;
    });
  }

  @override
  Future<void> acceptRide({
    required String rideId,
    required String driverId,
    required String driverName,
    required String driverPhone,
  }) async {
    final docRef = _rides.doc(rideId);

    await firebaseService.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw const ServerException('الرحلة دي مش موجودة.');
      }

      final currentStatus = RideStatusX.fromValue(snapshot.data()?['status']);

      if (currentStatus != RideStatus.pending) {
        throw const ServerException('سواق تاني سبقك وقبل الرحلة دي.');
      }

      transaction.update(docRef, {
        'driverId': driverId,
        'driverName': driverName,
        'driverPhone': driverPhone,
        'status': RideStatus.accepted.value,
        'acceptedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> rejectRide({
    required String rideId,
    required String driverId,
  }) async {
    await _rides.doc(rideId).update({
      'rejectedDriverIds': FieldValue.arrayUnion([driverId]),
    });
  }

  @override
  Future<void> driverArrived(String rideId) async {
    final docRef = _rides.doc(rideId);

    await firebaseService.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw const ServerException('الرحلة مش موجودة.');
      }

      final status = RideStatusX.fromValue(snapshot.data()?['status']);

      if (status != RideStatus.accepted) {
        throw const ServerException('مينفعش تسجل وصولك دلوقتي.');
      }

      transaction.update(docRef, {'status': RideStatus.arrived.value});
    });
  }

  @override
  Future<void> startTrip(String rideId) async {
    final docRef = _rides.doc(rideId);

    await firebaseService.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw const ServerException('الرحلة مش موجودة.');
      }

      final status = RideStatusX.fromValue(snapshot.data()?['status']);

      if (status != RideStatus.arrived) {
        throw const ServerException('لازم تسجل وصولك الأول.');
      }

      transaction.update(docRef, {'status': RideStatus.onTrip.value});
    });
  }

  @override
  Future<void> completeRide(String rideId) async {
    final docRef = _rides.doc(rideId);

    await firebaseService.firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (!snapshot.exists) {
        throw const ServerException('الرحلة مش موجودة.');
      }

      final status = RideStatusX.fromValue(snapshot.data()?['status']);

      if (status != RideStatus.onTrip) {
        throw const ServerException('ابدأ الرحلة الأول قبل ما تنهيها.');
      }

      transaction.update(docRef, {
        'status': RideStatus.completed.value,
        'completedAt': FieldValue.serverTimestamp(),
      });
    });
  }

  @override
  Future<void> cancelRide(String rideId) async {
    await _rides.doc(rideId).update({'status': RideStatus.cancelled.value});
  }

  @override
  Future<void> setDriverAvailability({
    required String driverId,
    required String driverName,
    required bool isOnline,
    double? lat,
    double? lng,
  }) async {
    await _drivers.doc(driverId).set({
      'name': driverName,
      'isOnline': isOnline,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  @override
  Future<void> updateDriverLocation({
    required String driverId,
    required double lat,
    required double lng,
  }) async {
    await _drivers.doc(driverId).set({
      'lat': lat,
      'lng': lng,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
