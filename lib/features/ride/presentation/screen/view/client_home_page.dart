import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_travel_10/core/constants/app_colors.dart';
import 'package:flutter_travel_10/core/constants/app_sizes.dart';
import 'package:flutter_travel_10/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_travel_10/features/ride/domain/entities/ride.dart';
import 'package:flutter_travel_10/features/ride/domain/entities/ride_status.dart';
import 'package:flutter_travel_10/features/ride/presentation/cubit/client_home_cubit.dart';
import 'package:flutter_travel_10/features/ride/presentation/cubit/client_home_state.dart';

class ClientHomeView extends StatefulWidget {
  const ClientHomeView({super.key});

  @override
  State<ClientHomeView> createState() => _ClientHomeViewState();
}

class _ClientHomeViewState extends State<ClientHomeView> {
  final MapController _mapController = MapController();

  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<ClientHomeCubit, ClientHomeState>(
        listener: (context, state) {
          if (state.errorMessage != null && state.errorMessage!.isNotEmpty) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  behavior: SnackBarBehavior.floating,
                ),
              );
          }

          if (state.pickup != null && state.destination == null) {
            _mapController.move(
              LatLng(state.pickup!.lat, state.pickup!.lng),
              15,
            );
          }
        },
        builder: (context, state) {
          final pickupLatLng =
              state.pickup != null
                  ? LatLng(state.pickup!.lat, state.pickup!.lng)
                  : null;

          final destinationLatLng =
              state.destination != null
                  ? LatLng(state.destination!.lat, state.destination!.lng)
                  : null;

          final driverLatLng =
              state.activeRide?.driverLocation != null
                  ? LatLng(
                    state.activeRide!.driverLocation!.lat,
                    state.activeRide!.driverLocation!.lng,
                  )
                  : null;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: pickupLatLng ?? _defaultLocation,
                  initialZoom: 14,
                  minZoom: 3,
                  maxZoom: 19,
                  onTap: (tapPosition, point) async {
                    if (state.activeRide != null) {
                      return;
                    }

                    await context
                        .read<ClientHomeCubit>()
                        .selectDestinationFromMap(
                          point.latitude,
                          point.longitude,
                        );
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.flutter_travel_10',
                  ),

                  if (pickupLatLng != null && destinationLatLng != null)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: [pickupLatLng, destinationLatLng],
                          strokeWidth: 4,
                          color: AppColors.primary,
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: [
                      if (pickupLatLng != null)
                        Marker(
                          point: pickupLatLng,
                          width: 55,
                          height: 55,
                          child: const Icon(
                            Icons.person_pin_circle,
                            color: Colors.blue,
                            size: 48,
                          ),
                        ),

                      if (destinationLatLng != null)
                        Marker(
                          point: destinationLatLng,
                          width: 55,
                          height: 55,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 48,
                          ),
                        ),

                      if (driverLatLng != null)
                        Marker(
                          point: driverLatLng,
                          width: 55,
                          height: 55,
                          child: const Icon(
                            Icons.directions_car,
                            color: AppColors.primary,
                            size: 42,
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _ClientHeader(clientName: _getClientName(context)),
              ),

              Positioned(
                right: 16,
                bottom: state.destination != null ? 280 : 180,
                child: _MapControls(
                  onMyLocation: () {
                    _moveToMyLocation(context);
                  },
                  onFitMap: () {
                    _fitMap(
                      pickup: pickupLatLng,
                      destination: destinationLatLng,
                    );
                  },
                ),
              ),

              if (state.isLoadingLocation)
                const Positioned(
                  top: 110,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text('جاري تحديد موقعك...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              if (state.isSearchingDestination)
                const Positioned(
                  top: 170,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 18,
                          vertical: 12,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 10),
                            Text('جاري تحديد الوجهة...'),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: _buildBottomPanel(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getClientName(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;

    return user?.name ?? 'الراكب';
  }

  Widget _buildBottomPanel(BuildContext context, ClientHomeState state) {
    if (state.activeRide != null) {
      return _ActiveRidePanel(
        ride: state.activeRide!,
        isProcessing: state.isRequesting,
        onCancel: () {
          context.read<ClientHomeCubit>().cancelActiveRide();
        },
      );
    }

    return _RequestRidePanel(
      state: state,
      isProcessing: state.isRequesting,
      onRequestRide: () {
        if (state.destination == null) {
          _showDestinationSheet(context);
        } else {
          context.read<ClientHomeCubit>().confirmRideRequest();
        }
      },
      onCancelDestination: () {
        context.read<ClientHomeCubit>().clearDestination();
      },
    );
  }

  void _showDestinationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const _Handle(),

                const SizedBox(height: 18),

                const Text(
                  'حدد وجهتك',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(sheetContext);

                      ScaffoldMessenger.of(context)
                        ..hideCurrentSnackBar()
                        ..showSnackBar(
                          const SnackBar(
                            content: Text('اضغط على الخريطة لتحديد وجهتك'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                    },
                    icon: const Icon(Icons.map),
                    label: const Text('اختيار من الخريطة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 10),

                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(sheetContext);
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text('إلغاء'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _moveToMyLocation(BuildContext context) {
    final pickup = context.read<ClientHomeCubit>().state.pickup;

    if (pickup == null) {
      context.read<ClientHomeCubit>().loadCurrentLocation();

      return;
    }

    _mapController.move(LatLng(pickup.lat, pickup.lng), 15);
  }

  void _fitMap({LatLng? pickup, LatLng? destination}) {
    if (pickup == null && destination == null) {
      return;
    }

    if (pickup != null && destination == null) {
      _mapController.move(pickup, 15);
      return;
    }

    if (pickup == null && destination != null) {
      _mapController.move(destination, 15);
      return;
    }

    final bounds = LatLngBounds(pickup!, destination!);

    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
    );
  }
}

class _MapControls extends StatelessWidget {
  final VoidCallback onMyLocation;
  final VoidCallback onFitMap;

  const _MapControls({required this.onMyLocation, required this.onFitMap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _MapButton(icon: Icons.my_location, onPressed: onMyLocation),
        const SizedBox(height: 10),
        _MapButton(icon: Icons.fit_screen, onPressed: onFitMap),
      ],
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _MapButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: AppColors.primary),
      ),
    );
  }
}

class _ClientHeader extends StatelessWidget {
  final String clientName;

  const _ClientHeader({required this.clientName});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 12,
                    ),
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
                            'أهلاً بك',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            clientName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(width: 10),

            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: () {
                  context.read<AuthCubit>().logout();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RequestRidePanel extends StatelessWidget {
  final ClientHomeState state;
  final bool isProcessing;
  final VoidCallback onRequestRide;
  final VoidCallback onCancelDestination;

  const _RequestRidePanel({
    required this.state,
    required this.isProcessing,
    required this.onRequestRide,
    required this.onCancelDestination,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Handle(),

          const SizedBox(height: 16),

          const Text(
            'أين تريد الذهاب اليوم؟',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 12),

          if (state.pickup != null)
            Row(
              children: [
                const Icon(Icons.my_location, color: Colors.blue),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.pickup!.address ?? 'موقع الاستلام الحالي',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),

          if (state.destination != null) ...[
            const SizedBox(height: 8),

            Row(
              children: [
                const Icon(Icons.location_on, color: Colors.red),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.destination!.address ?? 'الوجهة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],

          if (state.distanceKm != null && state.estimatedFare != null) ...[
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'المسافة: ${state.distanceKm!.toStringAsFixed(1)} كم',
                  style: const TextStyle(color: Colors.grey),
                ),
                Text(
                  '${state.estimatedFare!.toStringAsFixed(0)} ج',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ],

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton.icon(
              onPressed: isProcessing ? null : onRequestRide,
              icon: Icon(state.destination == null ? Icons.map : Icons.check),
              label: Text(
                state.destination == null
                    ? 'اختيار الوجهة'
                    : 'تأكيد طلب الرحلة',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ),

          if (state.destination != null) ...[
            const SizedBox(height: 10),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: isProcessing ? null : onCancelDestination,
                icon: const Icon(Icons.close),
                label: const Text('إلغاء اختيار الوجهة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ActiveRidePanel extends StatelessWidget {
  final Ride ride;
  final bool isProcessing;
  final VoidCallback onCancel;

  const _ActiveRidePanel({
    required this.ride,
    required this.isProcessing,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [BoxShadow(blurRadius: 20, color: Colors.black12)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const _Handle(),

          const SizedBox(height: 15),

          _ClientStatusHeader(status: ride.status),

          const SizedBox(height: 16),

          if (ride.driverName != null) ...[
            Row(
              children: [
                const CircleAvatar(
                  radius: 24,
                  child: Icon(Icons.directions_car),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ride.driverName!,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (ride.driverPhone != null)
                        Text(
                          ride.driverPhone!,
                          style: const TextStyle(color: Colors.grey),
                        ),
                    ],
                  ),
                ),

                Text(
                  '${ride.estimatedFare.toStringAsFixed(0)} ج',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),
          ],

          if (ride.status == RideStatus.pending)
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: isProcessing ? null : onCancel,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                ),
                child:
                    isProcessing
                        ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.red,
                            strokeWidth: 2,
                          ),
                        )
                        : const Text('إلغاء الطلب'),
              ),
            ),
        ],
      ),
    );
  }
}

class _ClientStatusHeader extends StatelessWidget {
  final RideStatus status;

  const _ClientStatusHeader({required this.status});

  @override
  Widget build(BuildContext context) {
    String title;
    IconData icon;
    Color color;

    switch (status) {
      case RideStatus.pending:
        title = 'جاري البحث عن كابتن...';
        icon = Icons.search;
        color = Colors.orange;
        break;

      case RideStatus.accepted:
        title = 'الكابتن في الطريق إليك';
        icon = Icons.directions_car;
        color = Colors.blue;
        break;

      case RideStatus.arrived:
        title = 'وصل الكابتن إلى موقعك';
        icon = Icons.person_pin_circle;
        color = Colors.green;
        break;

      case RideStatus.onTrip:
        title = 'الرحلة جارية الآن';
        icon = Icons.local_taxi;
        color = AppColors.primary;
        break;

      default:
        title = 'تفاصيل الرحلة';
        icon = Icons.local_taxi;
        color = AppColors.primary;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 28),

        const SizedBox(width: 10),

        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

class _Handle extends StatelessWidget {
  const _Handle();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 4,
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(10),
      ),
    );
  }
}
