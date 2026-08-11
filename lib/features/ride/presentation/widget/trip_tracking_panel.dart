import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';

import '../../domain/entities/ride.dart';
import '../../domain/entities/ride_status.dart';

class TripTrackingPanel extends StatelessWidget {
  final Ride ride;

  final VoidCallback? onCancel;
  final VoidCallback? onPrimaryAction;

  const TripTrackingPanel({
    super.key,
    required this.ride,
    this.onCancel,
    this.onPrimaryAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.borderRadiusXLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(top: false, child: _buildContent(context)),
    );
  }

  Widget _buildContent(BuildContext context) {
    switch (ride.status) {
      case RideStatus.pending:
        return _pendingView();

      case RideStatus.accepted:
        return _acceptedView();

      case RideStatus.arrived:
        return _arrivedView();

      case RideStatus.onTrip:
        return _onTripView();

      case RideStatus.completed:
        return _completedView();

      case RideStatus.cancelled:
        return _cancelledView();
    }
  }

  // ==========================================================
  // PENDING
  // ==========================================================

  Widget _pendingView() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(color: AppColors.primary),

        const SizedBox(height: 14),

        Text(
          AppStrings.searchingForDriver,
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        const Text(
          'بنبحثلك عن أقرب سواق متاح...',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),

        if (onCancel != null) ...[
          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: onCancel,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusMedium,
                  ),
                ),
              ),
              child: Text(
                AppStrings.cancelRide,
                style: AppTextStyles.buttonLarge.copyWith(
                  color: AppColors.error,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  // ==========================================================
  // ACCEPTED
  // ==========================================================

  Widget _acceptedView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.local_taxi, size: 45, color: AppColors.primary),

        const SizedBox(height: 8),

        const Text(
          'السواق في الطريق ليك',
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 18),

        _driverInfo(),

        const SizedBox(height: 16),

        _locationInfo(),
      ],
    );
  }

  // ==========================================================
  // ARRIVED
  // ==========================================================

  Widget _arrivedView() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 50),

        const SizedBox(height: 8),

        const Text(
          'السواق وصل عندك 🚕',
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 16),

        _driverInfo(),
      ],
    );
  }

  // ==========================================================
  // ON TRIP
  // ==========================================================

  Widget _onTripView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Icon(Icons.navigation, color: AppColors.primary, size: 48),

        const SizedBox(height: 8),

        const Text(
          'الرحلة شغالة',
          style: AppTextStyles.headlineMedium,
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            const Icon(Icons.location_on, color: AppColors.error),

            const SizedBox(width: 8),

            Expanded(
              child: Text(
                ride.destination.address,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.primary.withOpacity(.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              const Icon(Icons.payments, color: AppColors.primary),

              const SizedBox(width: 10),

              const Text('الأجرة', style: TextStyle(color: Colors.grey)),

              const Spacer(),

              Text(
                '${ride.estimatedFare.toStringAsFixed(0)} جنيه',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // COMPLETED
  // ==========================================================

  Widget _completedView() {
    return Column(
      children: [
        const Icon(Icons.check_circle, color: AppColors.success, size: 65),

        const SizedBox(height: 10),

        const Text('وصلت بالسلامة ❤️', style: AppTextStyles.headlineMedium),

        const SizedBox(height: 6),

        Text(
          'إجمالي الرحلة: ${ride.estimatedFare.toStringAsFixed(0)} جنيه',
          style: AppTextStyles.bodyLarge,
        ),

        const SizedBox(height: 20),

        _doneButton(),
      ],
    );
  }

  // ==========================================================
  // CANCELLED
  // ==========================================================

  Widget _cancelledView() {
    return Column(
      children: [
        const Icon(Icons.cancel, color: AppColors.error, size: 60),

        const SizedBox(height: 10),

        const Text('الرحلة اتلغت', style: AppTextStyles.headlineMedium),

        const SizedBox(height: 20),

        _doneButton(),
      ],
    );
  }

  // ==========================================================
  // DRIVER INFO
  // ==========================================================

  Widget _driverInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 25,
            backgroundColor: AppColors.primary,
            child: Icon(Icons.person, color: Colors.white),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ride.driverName ?? 'السواق',
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                if (ride.driverPhone != null)
                  Text(ride.driverPhone!, style: AppTextStyles.caption),
              ],
            ),
          ),

          Text(
            '${ride.estimatedFare.toStringAsFixed(0)} جنيه',
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // LOCATION
  // ==========================================================

  Widget _locationInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.location_on, color: AppColors.error),

        const SizedBox(width: 8),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'وجهتك',
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(ride.destination.address, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }

  // ==========================================================
  // DONE
  // ==========================================================

  Widget _doneButton() {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: onPrimaryAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
          ),
        ),
        child: Text(
          AppStrings.done,
          style: AppTextStyles.buttonLarge.copyWith(color: Colors.white),
        ),
      ),
    );
  }
}
