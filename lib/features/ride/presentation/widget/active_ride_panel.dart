import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_sizes.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/theme/text_styles.dart';
import '../../domain/entities/ride.dart';

/// اللوحة اللي بتظهر تحت للسواق بعد ما يقبل رحلة، وفيها زرار "إنهاء الرحلة"
class ActiveRidePanel extends StatelessWidget {
  final Ride ride;
  final bool isProcessing;
  final VoidCallback onCompleteTrip;

  const ActiveRidePanel({
    super.key,
    required this.ride,
    required this.isProcessing,
    required this.onCompleteTrip,
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
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: AppSizes.paddingMedium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.currentTrip,
                      style: AppTextStyles.caption,
                    ),
                    Text(
                      ride.riderName,
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${ride.estimatedFare.toStringAsFixed(0)} جنيه',
                style: AppTextStyles.headlineMedium,
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingMedium),

          Row(
            children: [
              const Icon(Icons.location_on, color: AppColors.error, size: 18),
              const SizedBox(width: AppSizes.paddingSmall),
              Expanded(
                child: Text(
                  ride.destination.address,
                  style: AppTextStyles.bodyLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSizes.paddingLarge),

          SizedBox(
            width: double.infinity,
            height: 55,
            child: ElevatedButton(
              onPressed: isProcessing ? null : onCompleteTrip,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppSizes.borderRadiusMedium,
                  ),
                ),
              ),
              child: isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      AppStrings.completeTrip,
                      style: AppTextStyles.buttonLarge.copyWith(
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
