import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter_travel_10/core/constants/app_colors.dart';
import 'package:flutter_travel_10/core/constants/app_sizes.dart';
import 'package:flutter_travel_10/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:flutter_travel_10/features/ride/domain/entities/ride.dart';
import 'package:flutter_travel_10/features/ride/domain/entities/ride_status.dart';
import 'package:flutter_travel_10/features/ride/presentation/cubit/driver_home_cubit.dart';
import 'package:flutter_travel_10/features/ride/presentation/cubit/driver_home_state.dart';

class DriverHomeView extends StatefulWidget {
  const DriverHomeView({super.key});

  @override
  State<DriverHomeView> createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<DriverHomeView> {
  final MapController _mapController = MapController();

  static const LatLng _defaultLocation = LatLng(30.0444, 31.2357);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<DriverHomeCubit, DriverHomeState>(
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

          if (state.driverLocation != null &&
              state.activeRide == null &&
              state.incomingRequest == null) {
            _mapController.move(state.driverLocation!, 15);
          }

          if (state.incomingRequest != null) {
            _fitRideOnMap(state.incomingRequest!);
          }

          if (state.activeRide != null) {
            _fitRideOnMap(state.activeRide!);
          }
        },
        builder: (context, state) {
          final driverLocation = state.driverLocation;

          final Ride? currentRide = state.activeRide ?? state.incomingRequest;

          final pickupLatLng =
              currentRide?.pickup != null
                  ? LatLng(currentRide!.pickup.lat, currentRide.pickup.lng)
                  : null;

          final destinationLatLng =
              currentRide?.destination != null
                  ? LatLng(
                    currentRide!.destination.lat,
                    currentRide.destination.lng,
                  )
                  : null;

          return Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: const MapOptions(
                  initialCenter: _defaultLocation,
                  initialZoom: 14,
                  minZoom: 3,
                  maxZoom: 19,
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
                      if (driverLocation != null)
                        Marker(
                          point: driverLocation,
                          width: 55,
                          height: 55,
                          child: const Icon(
                            Icons.directions_car,
                            color: AppColors.primary,
                            size: 42,
                          ),
                        ),
                      if (pickupLatLng != null)
                        Marker(
                          point: pickupLatLng,
                          width: 55,
                          height: 55,
                          child: const Icon(
                            Icons.person_pin_circle,
                            color: Colors.green,
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
                    ],
                  ),
                ],
              ),
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: _DriverHeader(
                  driverName: 'الكابتن',
                  isOnline: state.isOnline,
                  isProcessing: state.isProcessing,
                  onToggleOnline: (value) {
                    context.read<DriverHomeCubit>().toggleOnline(value);
                  },
                  onLogout: () {
                    _logout(context);
                  },
                ),
              ),
              Positioned(
                right: 16,
                top: 145,
                child: Column(
                  children: [
                    _MapButton(
                      icon: Icons.my_location,
                      tooltip: 'موقعي',
                      onPressed: () {
                        final location = state.driverLocation;

                        if (location != null) {
                          _mapController.move(location, 16);
                        } else {
                          context.read<DriverHomeCubit>().loadDriverLocation();
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    _MapButton(
                      icon: Icons.zoom_in_map,
                      tooltip: 'إظهار الرحلة',
                      onPressed: () {
                        if (state.activeRide != null) {
                          _fitRideOnMap(state.activeRide!);
                        } else if (state.incomingRequest != null) {
                          _fitRideOnMap(state.incomingRequest!);
                        } else if (state.driverLocation != null) {
                          _mapController.move(state.driverLocation!, 14);
                        }
                      },
                    ),
                  ],
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

  Future<void> _logout(BuildContext context) async {
    final driverCubit = context.read<DriverHomeCubit>();

    if (driverCubit.state.isOnline) {
      await driverCubit.toggleOnline(false);
    }

    if (!context.mounted) return;

    await context.read<AuthCubit>().logout();

    if (!context.mounted) return;

    Navigator.pop(context);
  }

  void _fitRideOnMap(Ride ride) {
    final points = <LatLng>[];

    points.add(LatLng(ride.pickup.lat, ride.pickup.lng));

    points.add(LatLng(ride.destination.lat, ride.destination.lng));

    final driverLocation = context.read<DriverHomeCubit>().state.driverLocation;

    if (driverLocation != null) {
      points.add(driverLocation);
    }

    if (points.isEmpty) return;

    if (points.length == 1) {
      _mapController.move(points.first, 15);
      return;
    }

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.fromLTRB(70, 180, 70, 300),
      ),
    );
  }

  Widget _buildBottomPanel(BuildContext context, DriverHomeState state) {
    if (state.activeRide != null) {
      return _ActiveRidePanel(
        ride: state.activeRide!,
        isProcessing: state.isProcessing,
        onArrived: () {
          context.read<DriverHomeCubit>().markArrived();
        },
        onStartTrip: () {
          context.read<DriverHomeCubit>().startTrip();
        },
        onCompleteRide: () {
          context.read<DriverHomeCubit>().completeActiveRide();
        },
      );
    }

    if (!state.isOnline) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.all(AppSizes.paddingMedium),
        padding: const EdgeInsets.all(AppSizes.paddingMedium),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 12,
            ),
          ],
        ),
        child: const Text(
          'أنت الآن غير متصل.\n'
          'فعّل زر الاتصال بالأعلى لاستقبال الرحلات.',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
      );
    }

    if (state.incomingRequest != null) {
      final ride = state.incomingRequest!;

      return _IncomingRequestPanel(
        ride: ride,
        isProcessing: state.isProcessing,
        onAccept: () {
          context.read<DriverHomeCubit>().acceptRequest(ride);
        },
        onReject: () {
          context.read<DriverHomeCubit>().rejectRequest(ride);
        },
      );
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(AppSizes.paddingMedium),
      padding: const EdgeInsets.all(AppSizes.paddingMedium),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 12),
        ],
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
          SizedBox(width: 12),
          Text(
            'أنت متصل الآن. جاري البحث عن رحلات...',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  final String driverName;
  final bool isOnline;
  final bool isProcessing;
  final ValueChanged<bool> onToggleOnline;
  final VoidCallback onLogout;

  const _DriverHeader({
    required this.driverName,
    required this.isOnline,
    required this.isProcessing,
    required this.onToggleOnline,
    required this.onLogout,
  });

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
                            'أهلاً بك يا كابتن',
                            style: TextStyle(fontSize: 11, color: Colors.grey),
                          ),
                          Text(
                            driverName,
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
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 10,
                  ),
                ],
              ),
              child: Row(
                children: [
                  Switch(
                    value: isOnline,
                    activeColor: Colors.green,
                    onChanged: isProcessing ? null : onToggleOnline,
                  ),
                  Text(
                    isOnline ? 'متصل' : 'غير متصل',
                    style: TextStyle(
                      color: isOnline ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                  const SizedBox(width: 4),
                ],
              ),
            ),
            const SizedBox(width: 8),
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
                tooltip: 'تسجيل الخروج',
                onPressed: isProcessing ? null : onLogout,
                icon: const Icon(Icons.logout, color: Colors.red),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MapButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _MapButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 5,
      shape: const CircleBorder(),
      child: InkWell(
        onTap: onPressed,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Icon(icon, color: AppColors.primary, size: 24),
          ),
        ),
      ),
    );
  }
}

class _IncomingRequestPanel extends StatelessWidget {
  final Ride ride;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _IncomingRequestPanel({
    required this.ride,
    required this.isProcessing,
    required this.onAccept,
    required this.onReject,
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
          const SizedBox(height: 14),
          const Row(
            children: [
              Icon(
                Icons.notifications_active,
                color: AppColors.primary,
                size: 28,
              ),
              SizedBox(width: 10),
              Text(
                'طلب رحلة جديد!',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _RideInfoRow(
            icon: Icons.person,
            color: Colors.blue,
            title: 'الراكب',
            value: ride.riderName,
          ),
          const SizedBox(height: 10),
          _RideInfoRow(
            icon: Icons.my_location,
            color: Colors.green,
            title: 'مكان الاستلام',
            value: ride.pickup.address ?? 'موقع الاستلام',
          ),
          const SizedBox(height: 10),
          _RideInfoRow(
            icon: Icons.location_on,
            color: Colors.red,
            title: 'الوجهة',
            value: ride.destination.address ?? 'الوجهة',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _SmallInfoCard(
                  title: 'المسافة',
                  value: '${ride.distanceKm.toStringAsFixed(1)} كم',
                  icon: Icons.route,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallInfoCard(
                  title: 'الأجرة',
                  value: '${ride.estimatedFare.toStringAsFixed(0)} ج',
                  icon: Icons.payments,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: isProcessing ? null : onAccept,
                    icon: const Icon(Icons.check),
                    label: const Text('قبول الرحلة'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
                    onPressed: isProcessing ? null : onReject,
                    icon: const Icon(Icons.close),
                    label: const Text('رفض'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (isProcessing) ...[
            const SizedBox(height: 12),
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
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
  final VoidCallback onArrived;
  final VoidCallback onStartTrip;
  final VoidCallback onCompleteRide;

  const _ActiveRidePanel({
    required this.ride,
    required this.isProcessing,
    required this.onArrived,
    required this.onStartTrip,
    required this.onCompleteRide,
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
          const SizedBox(height: 14),
          Text(
            'الراكب: ${ride.riderName}',
            style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _RideInfoRow(
            icon: Icons.my_location,
            color: Colors.green,
            title: 'الاستلام',
            value: ride.pickup.address ?? 'مكان الاستلام',
          ),
          const SizedBox(height: 8),
          _RideInfoRow(
            icon: Icons.location_on,
            color: Colors.red,
            title: 'الوجهة',
            value: ride.destination.address ?? 'الوجهة',
          ),
          const SizedBox(height: 12),
          Text(
            '${ride.estimatedFare.toStringAsFixed(0)} ج',
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 14),
          if (ride.status == RideStatus.accepted)
            _ActionButton(
              text: 'وصلت لموقع الراكب',
              icon: Icons.location_on,
              color: Colors.blue,
              onPressed: isProcessing ? null : onArrived,
            ),
          if (ride.status == RideStatus.arrived)
            _ActionButton(
              text: 'بدء الرحلة',
              icon: Icons.play_arrow,
              color: Colors.orange,
              onPressed: isProcessing ? null : onStartTrip,
            ),
          if (ride.status == RideStatus.onTrip)
            _ActionButton(
              text: 'إنهاء الرحلة واستلام المبلغ',
              icon: Icons.check_circle,
              color: Colors.green,
              onPressed: isProcessing ? null : onCompleteRide,
            ),
        ],
      ),
    );
  }
}

class _RideInfoRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const _RideInfoRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 10),
        Text('$title: ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}

class _SmallInfoCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SmallInfoCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
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
