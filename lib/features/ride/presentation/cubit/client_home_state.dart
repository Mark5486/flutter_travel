import 'package:equatable/equatable.dart';

import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_location.dart';

class ClientHomeState extends Equatable {
  final bool isLoadingLocation;
  final bool isSearchingDestination;
  final bool isRequesting;

  final RideLocation? pickup;
  final RideLocation? destination;

  final double? distanceKm;
  final double? estimatedFare;

  final Ride? activeRide;

  final String? errorMessage;

  const ClientHomeState({
    this.isLoadingLocation = false,
    this.isSearchingDestination = false,
    this.isRequesting = false,
    this.pickup,
    this.destination,
    this.distanceKm,
    this.estimatedFare,
    this.activeRide,
    this.errorMessage,
  });

  bool get hasDestinationSelected => destination != null;

  bool get hasPickupSelected => pickup != null;

  bool get canRequestRide =>
      pickup != null &&
      destination != null &&
      distanceKm != null &&
      estimatedFare != null &&
      !isRequesting;

  ClientHomeState copyWith({
    bool? isLoadingLocation,
    bool? isSearchingDestination,
    bool? isRequesting,

    RideLocation? pickup,
    RideLocation? destination,

    bool clearPickup = false,
    bool clearDestination = false,

    double? distanceKm,
    double? estimatedFare,

    Ride? activeRide,
    bool clearActiveRide = false,

    String? errorMessage,
    bool clearError = false,
  }) {
    return ClientHomeState(
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,

      isSearchingDestination:
          isSearchingDestination ?? this.isSearchingDestination,

      isRequesting: isRequesting ?? this.isRequesting,

      pickup: clearPickup ? null : pickup ?? this.pickup,

      destination: clearDestination ? null : destination ?? this.destination,

      distanceKm: clearDestination ? null : distanceKm ?? this.distanceKm,

      estimatedFare:
          clearDestination ? null : estimatedFare ?? this.estimatedFare,

      activeRide: clearActiveRide ? null : activeRide ?? this.activeRide,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    isLoadingLocation,
    isSearchingDestination,
    isRequesting,
    pickup,
    destination,
    distanceKm,
    estimatedFare,
    activeRide,
    errorMessage,
  ];
}
