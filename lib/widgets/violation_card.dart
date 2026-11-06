import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_radius.dart';
import '../core/theme/app_typography.dart';
import '../core/utils/date_formatter.dart';
import '../models/violation_model.dart';
import 'status_badge.dart';

class ViolationCard extends StatelessWidget {
  const ViolationCard({super.key, required this.violation, this.onTap});

  final ViolationModel violation;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.outline),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.035),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.lgAll,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(vehicleType: violation.vehicleType),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              violation.id,
                              style: AppTypography.subtitle.copyWith(
                                fontSize: 14,
                              ),
                            ),
                          ),
                          StatusBadge.violation(
                            violation.status,
                            compact: true,
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            _vehicleIcon(violation.vehicleType),
                            size: 14,
                            color: AppColors.blue,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            violation.vehicleType.label,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.blue,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (violation.plateNumber != null) ...[
                            Text(
                              '  •  ',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            Flexible(
                              child: Text(
                                violation.plateNumber!,
                                overflow: TextOverflow.ellipsis,
                                style: AppTypography.caption,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(
                            Icons.schedule_rounded,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              DateFormatter.dateTime(violation.occurredAt),
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 13,
                            color: AppColors.textMuted,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              violation.location,
                              overflow: TextOverflow.ellipsis,
                              style: AppTypography.labelSmall,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _vehicleIcon(VehicleType type) => switch (type) {
    VehicleType.motorcycle => Icons.two_wheeler_rounded,
    VehicleType.car => Icons.directions_car_rounded,
    VehicleType.unknown => Icons.help_outline_rounded,
  };
}

class _Thumbnail extends StatelessWidget {
  const _Thumbnail({required this.vehicleType});

  final VehicleType vehicleType;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 68,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.navy.withValues(alpha: 0.9),
            AppColors.blue.withValues(alpha: 0.75),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 0,
            right: 0,
            top: 14,
            child: Icon(
              vehicleType == VehicleType.car
                  ? Icons.directions_car_rounded
                  : Icons.two_wheeler_rounded,
              color: Colors.white.withValues(alpha: 0.9),
              size: 28,
            ),
          ),
          Positioned(
            left: 8,
            right: 8,
            bottom: 9,
            child: Container(
              height: 3,
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
