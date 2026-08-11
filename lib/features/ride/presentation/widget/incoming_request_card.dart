import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/ride.dart';

class IncomingRequestCard extends StatelessWidget {
  final Ride ride;
  final bool isProcessing;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const IncomingRequestCard({
    super.key,
    required this.ride,
    required this.isProcessing,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLarge),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.borderRadiusXLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSizes.paddingMedium),
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),

          Text(
            AppStrings.newRideRequest,
            style: AppTextStyles.headlineMedium,
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          Text(
            ride.riderName,
            style: AppTextStyles.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          _LocationRow(
            icon: Icons.my_location,
            iconColor: AppColors.success,
            label: AppStrings.pickupFrom,
            address: ride.pickup.address,
          ),

          const SizedBox(height: AppSizes.paddingSmall),

          _LocationRow(
            icon: Icons.location_on,
            iconColor: AppColors.error,
            label: AppStrings.dropAt,
            address: ride.destination.address,
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          Row(
            children: [
              Expanded(
                child: _InfoChip(
                  label: AppStrings.tripDistance,
                  value: '${ride.distanceKm.toStringAsFixed(1)} كم',
                ),
              ),
              const SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: _InfoChip(
                  label: AppStrings.tripFare,
                  value: '${ride.estimatedFare.toStringAsFixed(0)} جنيه',
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : onReject,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingMedium,
                    ),
                    side: const BorderSide(color: AppColors.error),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusMedium,
                      ),
                    ),
                  ),
                  child: Text(
                    AppStrings.reject,
                    style: AppTextStyles.buttonLarge.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppSizes.paddingMedium),

              Expanded(
                child: ElevatedButton(
                  onPressed: isProcessing ? null : onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.success,
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSizes.paddingMedium,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        AppSizes.borderRadiusMedium,
                      ),
                    ),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          AppStrings.accept,
                          style: AppTextStyles.buttonLarge.copyWith(
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationRow extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String address;

  const _LocationRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: iconColor, size: AppSizes.iconSizeMedium),
        const SizedBox(width: AppSizes.paddingSmall),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTextStyles.caption),
              Text(address, style: AppTextStyles.bodyLarge),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final String value;

  const _InfoChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSizes.paddingSmall,
        horizontal: AppSizes.paddingMedium,
      ),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSizes.borderRadiusMedium),
      ),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.caption),
          Text(
            value,
            style: AppTextStyles.bodyLarge.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
