import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_travel_10/features/ride/presentation/widget/fare_estimate_sheet.dart';
import 'package:flutter_travel_10/features/ride/presentation/widget/trip_tracking_panel.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_status.dart';
import '../cubit/client_home_cubit.dart';
import '../cubit/client_home_state.dart';

class ClientHomePage extends StatefulWidget {
  final AppUser rider;

  const ClientHomePage({super.key, required this.rider});

  @override
  State<ClientHomePage> createState() => _ClientHomePageState();
}

class _ClientHomePageState extends State<ClientHomePage> {
  final MapController _mapController = MapController();

  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  LatLng? _pickupMarker;
  LatLng? _destinationMarker;
  LatLng? _driverMarker;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ClientHomeCubit>().loadCurrentLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ClientHomeCubit, ClientHomeState>(
      listener: (context, state) {
        _syncMarkers(state);

        final ride = state.activeRide;

        if (ride != null && ride.status == RideStatus.completed) {
          _moveToRideLocation(
            LatLng(ride.destination.lat, ride.destination.lng),
          );
        }

        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: BlocBuilder<ClientHomeCubit, ClientHomeState>(
        builder: (context, state) {
          return Scaffold(
            body: Stack(
              children: [
                _buildMap(state),

                _ClientHeader(rider: widget.rider),

                if (state.activeRide == null)
                  _buildHomeBottom(state)
                else
                  _buildTripPanel(state),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // MAP
  // ==========================================================

  Widget _buildMap(ClientHomeState state) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _defaultLocation,
        initialZoom: 14,
        minZoom: 3,
        maxZoom: 19,

        onTap: (tapPosition, point) {
          _handleMapTap(point, state);
        },
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.flutter_travel_10',
        ),

        MarkerLayer(
          markers: [
            if (_pickupMarker != null)
              Marker(
                point: _pickupMarker!,
                width: 55,
                height: 55,
                child: const _PickupMarker(),
              ),

            if (_destinationMarker != null)
              Marker(
                point: _destinationMarker!,
                width: 55,
                height: 55,
                child: const _DestinationMarker(),
              ),

            if (_driverMarker != null)
              Marker(
                point: _driverMarker!,
                width: 60,
                height: 60,
                child: const _DriverMarker(),
              ),
          ],
        ),
      ],
    );
  }

  // ==========================================================
  // MARKERS
  // ==========================================================

  void _syncMarkers(ClientHomeState state) {
    final pickup = state.pickup;
    final destination = state.destination;
    final ride = state.activeRide;

    final driverLocation = ride?.driverLocation;

    setState(() {
      _pickupMarker = pickup == null ? null : LatLng(pickup.lat, pickup.lng);

      _destinationMarker =
          destination == null ? null : LatLng(destination.lat, destination.lng);

      _driverMarker =
          driverLocation == null
              ? null
              : LatLng(driverLocation.lat, driverLocation.lng);
    });
  }

  // ==========================================================
  // MAP TAP
  // ==========================================================

  void _handleMapTap(LatLng point, ClientHomeState state) {
    final cubit = context.read<ClientHomeCubit>();

    if (state.pickup == null) {
      cubit.selectDestinationFromMap(point.latitude, point.longitude);
      return;
    }

    if (state.destination == null) {
      cubit.selectDestinationFromMap(point.latitude, point.longitude);
    }
  }

  // ==========================================================
  // CURRENT LOCATION
  // ==========================================================

  Future<void> _selectCurrentLocation() async {
    await context.read<ClientHomeCubit>().loadCurrentLocation();

    final state = context.read<ClientHomeCubit>().state;

    final pickup = state.pickup;

    if (pickup == null) return;

    _moveToRideLocation(LatLng(pickup.lat, pickup.lng), zoom: 16);
  }

  void _moveToRideLocation(LatLng location, {double zoom = 15}) {
    _mapController.move(location, zoom);
  }

  // ==========================================================
  // HOME BOTTOM
  // ==========================================================

  Widget _buildHomeBottom(ClientHomeState state) {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 20,
      child: SafeArea(
        top: false,
        child: _ClientBottomCard(
          state: state,
          onSelectLocation: _selectCurrentLocation,
          onRequestRide: () {
            _openFareSheet(state);
          },
        ),
      ),
    );
  }

  // ==========================================================
  // FARE SHEET
  // ==========================================================

  void _openFareSheet(ClientHomeState state) {
    if (!state.canRequestRide) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('حدد مكان الاستلام والوجهة الأول.')),
      );

      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return FareEstimateSheet(
          destinationAddress: state.destination!.address,
          distanceKm: state.distanceKm!,
          estimatedFare: state.estimatedFare!,
          isRequesting: state.isRequesting,

          onCancel: () {
            Navigator.pop(context);
          },

          onConfirm: () async {
            Navigator.pop(context);

            await context.read<ClientHomeCubit>().confirmRideRequest();
          },
        );
      },
    );
  }

  // ==========================================================
  // TRIP PANEL
  // ==========================================================

  Widget _buildTripPanel(ClientHomeState state) {
    final ride = state.activeRide;

    if (ride == null) {
      return const SizedBox.shrink();
    }

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: TripTrackingPanel(
        ride: ride,

        onCancel:
            ride.status == RideStatus.pending
                ? () {
                  context.read<ClientHomeCubit>().cancelActiveRide();
                }
                : null,

        onPrimaryAction:
            ride.status == RideStatus.completed ||
                    ride.status == RideStatus.cancelled
                ? () {
                  context.read<ClientHomeCubit>().dismissFinishedRide();
                }
                : null,
      ),
    );
  }
}

// ============================================================
// HEADER
// ============================================================

class _ClientHeader extends StatelessWidget {
  final AppUser rider;

  const _ClientHeader({required this.rider});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSizes.paddingMedium),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 12),
              ],
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.person, color: Colors.white),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'أهلاً بيك',
                        style: TextStyle(fontSize: 11, color: Colors.grey),
                      ),

                      Text(
                        rider.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: () {
                    context.read<AuthCubit>().logout();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CLIENT BOTTOM CARD
// ============================================================

class _ClientBottomCard extends StatelessWidget {
  final ClientHomeState state;

  final VoidCallback onSelectLocation;
  final VoidCallback onRequestRide;

  const _ClientBottomCard({
    required this.state,
    required this.onSelectLocation,
    required this.onRequestRide,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 18)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'إلى أين تريد الذهاب؟',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 14),

          // PICKUP
          InkWell(
            onTap: onSelectLocation,
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  Icon(Icons.my_location, color: AppColors.primary),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'مكان الاستلام',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),

                        Text(
                          state.pickup?.address ?? 'حدد موقع الاستلام',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (state.isLoadingLocation)
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  else
                    const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // DESTINATION
          InkWell(
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('اضغط على الخريطة لتحديد وجهتك')),
              );
            },
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Row(
                children: [
                  const Icon(Icons.location_on, color: Colors.red),

                  const SizedBox(width: 10),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'الوجهة',
                          style: TextStyle(fontSize: 11, color: Colors.grey),
                        ),

                        Text(
                          state.destination?.address ??
                              'اضغط على الخريطة لتحديد وجهتك',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Icon(Icons.arrow_forward_ios, size: 16),
                ],
              ),
            ),
          ),

          if (state.destination != null &&
              state.distanceKm != null &&
              state.estimatedFare != null) ...[
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: _SmallInfo(
                    icon: Icons.route,
                    title: 'المسافة',
                    value: '${state.distanceKm!.toStringAsFixed(1)} كم',
                  ),
                ),

                const SizedBox(width: 8),

                Expanded(
                  child: _SmallInfo(
                    icon: Icons.payments,
                    title: 'السعر التقريبي',
                    value: '${state.estimatedFare!.toStringAsFixed(0)} جنيه',
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: state.canRequestRide ? onRequestRide : null,
              icon: const Icon(Icons.local_taxi),
              label: const Text(
                'اطلب رحلة',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SMALL INFO
// ============================================================

class _SmallInfo extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _SmallInfo({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.primary),

          const SizedBox(width: 7),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PICKUP MARKER
// ============================================================

class _PickupMarker extends StatelessWidget {
  const _PickupMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.green,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: const Icon(Icons.my_location, color: Colors.white, size: 28),
    );
  }
}

// ============================================================
// DESTINATION MARKER
// ============================================================

class _DestinationMarker extends StatelessWidget {
  const _DestinationMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: const Icon(Icons.location_on, color: Colors.white, size: 30),
    );
  }
}

// ============================================================
// DRIVER MARKER
// ============================================================

class _DriverMarker extends StatelessWidget {
  const _DriverMarker();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.primary,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 10)],
      ),
      child: const Icon(Icons.local_taxi, color: Colors.white, size: 30),
    );
  }
}
