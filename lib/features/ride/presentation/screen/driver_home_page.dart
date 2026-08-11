import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/di/ride_locator.dart' as ride_di;

import '../../../auth/domain/entities/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';

import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_status.dart';

import '../../domain/usecase/accept_ride_usecase.dart';
import '../../domain/usecase/complete_ride_usecase.dart';
import '../../domain/usecase/driver_arrived_usecase.dart';
import '../../domain/usecase/reject_ride_usecase.dart';
import '../../domain/usecase/set_driver_availability_usecase.dart';
import '../../domain/usecase/start_trip_usecase.dart';
import '../../domain/usecase/update_driver_location_usecase.dart';
import '../../domain/usecase/watch_active_ride_for_driver_usecase.dart';
import '../../domain/usecase/watch_incoming_requests_usecase.dart';

import '../cubit/driver_home_cubit.dart';
import '../cubit/driver_home_state.dart';

class DriverHomePage extends StatelessWidget {
  final AppUser driver;

  const DriverHomePage({super.key, required this.driver});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (_) => DriverHomeCubit(
            driverId: driver.uid,
            driverName: driver.name,
            driverPhone: driver.phone,

            locationService: ride_di.getIt(),

            setDriverAvailabilityUseCase:
                ride_di.getIt<SetDriverAvailabilityUseCase>(),

            updateDriverLocationUseCase:
                ride_di.getIt<UpdateDriverLocationUseCase>(),

            watchIncomingRequestsUseCase:
                ride_di.getIt<WatchIncomingRequestsUseCase>(),

            watchActiveRideForDriverUseCase:
                ride_di.getIt<WatchActiveRideForDriverUseCase>(),

            acceptRideUseCase: ride_di.getIt<AcceptRideUseCase>(),

            rejectRideUseCase: ride_di.getIt<RejectRideUseCase>(),

            driverArrivedUseCase: ride_di.getIt<DriverArrivedUseCase>(),

            startTripUseCase: ride_di.getIt<StartTripUseCase>(),

            completeRideUseCase: ride_di.getIt<CompleteRideUseCase>(),
          ),
      child: const _DriverHomeView(),
    );
  }
}

class _DriverHomeView extends StatefulWidget {
  const _DriverHomeView();

  @override
  State<_DriverHomeView> createState() => _DriverHomeViewState();
}

class _DriverHomeViewState extends State<_DriverHomeView> {
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
              ..showSnackBar(SnackBar(content: Text(state.errorMessage!)));
          }

          if (state.driverLocation != null) {
            _mapController.move(state.driverLocation!, 16);
          }
        },
        builder: (context, state) {
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

                  if (state.driverLocation != null)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: state.driverLocation!,
                          width: 60,
                          height: 60,
                          child: _DriverCarMarker(isOnline: state.isOnline),
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
                  driverName: driverName(context),
                  isOnline: state.isOnline,
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  top: false,
                  child: _buildBottomController(context, state),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String driverName(BuildContext context) {
    final user = context.read<AuthCubit>().state.user;

    return user?.name ?? 'السواق';
  }

  Widget _buildBottomController(BuildContext context, DriverHomeState state) {
    if (state.activeRide != null) {
      return _ActiveRideController(
        ride: state.activeRide!,
        isProcessing: state.isProcessing,
        onArrived: () {
          context.read<DriverHomeCubit>().markArrived();
        },
        onStartTrip: () {
          context.read<DriverHomeCubit>().startTrip();
        },
        onComplete: () {
          context.read<DriverHomeCubit>().completeActiveRide();
        },
      );
    }

    if (state.incomingRequest != null && state.isOnline) {
      return _IncomingRequestController(
        ride: state.incomingRequest!,
        isProcessing: state.isProcessing,
        onAccept: () {
          context.read<DriverHomeCubit>().acceptRequest(state.incomingRequest!);
        },
        onReject: () {
          context.read<DriverHomeCubit>().rejectRequest(state.incomingRequest!);
        },
      );
    }

    return _DriverOnlineController(
      isOnline: state.isOnline,
      isProcessing: state.isProcessing,
      onChanged: (value) {
        context.read<DriverHomeCubit>().toggleOnline(value);
      },
    );
  }
}

class _DriverCarMarker extends StatelessWidget {
  final bool isOnline;

  const _DriverCarMarker({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: isOnline ? AppColors.primary : Colors.grey,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 4),
        boxShadow: const [
          BoxShadow(color: Colors.black26, blurRadius: 8, spreadRadius: 1),
        ],
      ),
      child: const Icon(Icons.directions_car, color: Colors.white, size: 28),
    );
  }
}

class _DriverHeader extends StatelessWidget {
  final String driverName;
  final bool isOnline;

  const _DriverHeader({required this.driverName, required this.isOnline});

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
                      color: Colors.black.withOpacity(.12),
                      blurRadius: 12,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),

                    const SizedBox(width: 10),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'أهلاً يا كابتن',
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

                    _OnlineBadge(isOnline: isOnline),
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
                    color: Colors.black.withOpacity(.12),
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

class _OnlineBadge extends StatelessWidget {
  final bool isOnline;

  const _OnlineBadge({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    final color = isOnline ? Colors.green : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            isOnline ? 'متصل' : 'غير متصل',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _DriverOnlineController extends StatelessWidget {
  final bool isOnline;
  final bool isProcessing;
  final ValueChanged<bool> onChanged;

  const _DriverOnlineController({
    required this.isOnline,
    required this.isProcessing,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color:
                      isOnline
                          ? Colors.green.withOpacity(.12)
                          : Colors.grey.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isOnline ? Icons.wifi : Icons.wifi_off,
                  color: isOnline ? Colors.green : Colors.grey,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حالة الكابتن',
                      style: TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    Text(
                      'استقبل رحلات جديدة',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              Switch.adaptive(
                value: isOnline,
                onChanged: isProcessing ? null : onChanged,
                activeColor: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            isOnline
                ? 'أنت متاح حاليًا لاستقبال الرحلات'
                : 'افتح حالتك عشان تبدأ تستقبل رحلات',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),

          if (isProcessing) ...[
            const SizedBox(height: 14),
            const LinearProgressIndicator(),
          ],
        ],
      ),
    );
  }
}

class _IncomingRequestController extends StatelessWidget {
  final Ride ride;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const _IncomingRequestController({
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
          _Handle(),

          const SizedBox(height: 15),

          const Text(
            '🚕 طلب رحلة جديد',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              const CircleAvatar(radius: 24, child: Icon(Icons.person)),

              const SizedBox(width: 10),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.riderName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      ride.riderPhone,
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

          const SizedBox(height: 18),

          _RideLocationRow(
            icon: Icons.my_location,
            color: Colors.green,
            title: 'الاستلام',
            address: ride.pickup.address,
          ),

          const SizedBox(height: 10),

          _RideLocationRow(
            icon: Icons.location_on,
            color: Colors.red,
            title: 'الوجهة',
            address: ride.destination.address,
          ),

          const SizedBox(height: 18),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child: const Text('رفض'),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: ElevatedButton(
                  onPressed: isProcessing ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                  ),
                  child:
                      isProcessing
                          ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Text('قبول الرحلة'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActiveRideController extends StatelessWidget {
  final Ride ride;
  final bool isProcessing;
  final VoidCallback onArrived;
  final VoidCallback onStartTrip;
  final VoidCallback onComplete;

  const _ActiveRideController({
    required this.ride,
    required this.isProcessing,
    required this.onArrived,
    required this.onStartTrip,
    required this.onComplete,
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
          _Handle(),

          const SizedBox(height: 15),

          _StatusHeader(status: ride.status),

          const SizedBox(height: 18),

          Row(
            children: [
              const CircleAvatar(radius: 25, child: Icon(Icons.person)),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ride.riderName,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ride.riderPhone,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),

              Text(
                '${ride.estimatedFare.toStringAsFixed(0)} ج',
                style: const TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          _RideLocationRow(
            icon: Icons.my_location,
            color: Colors.green,
            title: 'مكان الراكب',
            address: ride.pickup.address,
          ),

          const SizedBox(height: 10),

          _RideLocationRow(
            icon: Icons.location_on,
            color: Colors.red,
            title: 'الوجهة',
            address: ride.destination.address,
          ),

          const SizedBox(height: 18),

          _buildActionButton(),
        ],
      ),
    );
  }

  Widget _buildActionButton() {
    switch (ride.status) {
      case RideStatus.accepted:
        return _ActionButton(
          text: 'وصلت للراكب',
          icon: Icons.location_on,
          color: Colors.orange,
          isProcessing: isProcessing,
          onPressed: onArrived,
        );

      case RideStatus.arrived:
        return _ActionButton(
          text: 'ابدأ الرحلة',
          icon: Icons.play_arrow,
          color: Colors.green,
          isProcessing: isProcessing,
          onPressed: onStartTrip,
        );

      case RideStatus.onTrip:
        return _ActionButton(
          text: 'إنهاء الرحلة',
          icon: Icons.flag,
          color: AppColors.primary,
          isProcessing: isProcessing,
          onPressed: onComplete,
        );

      default:
        return const SizedBox.shrink();
    }
  }
}

class _StatusHeader extends StatelessWidget {
  final RideStatus status;

  const _StatusHeader({required this.status});

  @override
  Widget build(BuildContext context) {
    String title;
    IconData icon;
    Color color;

    switch (status) {
      case RideStatus.accepted:
        title = 'في الطريق للراكب';
        icon = Icons.directions_car;
        color = Colors.orange;
        break;

      case RideStatus.arrived:
        title = 'وصلت لمكان الراكب';
        icon = Icons.person_pin_circle;
        color = Colors.green;
        break;

      case RideStatus.onTrip:
        title = 'الرحلة جارية';
        icon = Icons.local_taxi;
        color = AppColors.primary;
        break;

      default:
        title = 'رحلة نشطة';
        icon = Icons.local_taxi;
        color = AppColors.primary;
    }

    return Row(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final Color color;
  final bool isProcessing;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.text,
    required this.icon,
    required this.color,
    required this.isProcessing,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 55,
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: isProcessing ? null : onPressed,
        icon:
            isProcessing
                ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                : Icon(icon),
        label: Text(
          text,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ),
    );
  }
}

class _RideLocationRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String address;

  const _RideLocationRow({
    required this.icon,
    required this.color,
    required this.title,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              const SizedBox(height: 2),
              Text(
                address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
