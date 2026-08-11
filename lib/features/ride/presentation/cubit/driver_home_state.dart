import 'package:equatable/equatable.dart';
import 'package:latlong2/latlong.dart';

import '../../domain/entities/ride.dart';

class DriverHomeState extends Equatable {
  final bool isOnline;
  final bool isProcessing;

  final Ride? incomingRequest;
  final Ride? activeRide;

  /// موقع السواق الحالي على الخريطة
  final LatLng? driverLocation;

  final String? errorMessage;

  const DriverHomeState({
    this.isOnline = false,
    this.isProcessing = false,
    this.incomingRequest,
    this.activeRide,
    this.driverLocation,
    this.errorMessage,
  });

  DriverHomeState copyWith({
    bool? isOnline,
    bool? isProcessing,

    Ride? incomingRequest,
    bool clearIncomingRequest = false,

    Ride? activeRide,
    bool clearActiveRide = false,

    LatLng? driverLocation,
    bool clearDriverLocation = false,

    String? errorMessage,
    bool clearError = false,
  }) {
    return DriverHomeState(
      isOnline: isOnline ?? this.isOnline,
      isProcessing: isProcessing ?? this.isProcessing,

      incomingRequest:
          clearIncomingRequest ? null : incomingRequest ?? this.incomingRequest,

      activeRide: clearActiveRide ? null : activeRide ?? this.activeRide,

      driverLocation:
          clearDriverLocation ? null : driverLocation ?? this.driverLocation,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isOnline,
    isProcessing,
    incomingRequest,
    activeRide,
    driverLocation,
    errorMessage,
  ];
}
