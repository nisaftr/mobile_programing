import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../models/notification_model.dart';
import '../models/violation_model.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.background,
    this.icon,
    this.compact = false,
  });

  final String label;
  final Color color;
  final Color? background;
  final IconData? icon;
  final bool compact;

  factory StatusBadge.violation(
    ViolationStatus status, {
    bool compact = false,
  }) {
    final color = switch (status) {
      ViolationStatus.pending => AppColors.warning,
      ViolationStatus.verified => AppColors.success,
      ViolationStatus.invalid => AppColors.danger,
    };
    final background = switch (status) {
      ViolationStatus.pending => AppColors.warningSoft,
      ViolationStatus.verified => AppColors.successSoft,
      ViolationStatus.invalid => AppColors.dangerSoft,
    };
    final icon = switch (status) {
      ViolationStatus.pending => Icons.schedule_rounded,
      ViolationStatus.verified => Icons.verified_rounded,
      ViolationStatus.invalid => Icons.cancel_rounded,
    };
    return StatusBadge(
      label: status.shortLabel,
      color: color,
      background: background,
      icon: icon,
      compact: compact,
    );
  }

  factory StatusBadge.notification(
    NotificationCategory category, {
    bool compact = false,
  }) {
    final color = switch (category) {
      NotificationCategory.violation => AppColors.danger,
      NotificationCategory.camera => AppColors.warning,
      NotificationCategory.system => AppColors.blue,
    };
    final background = switch (category) {
      NotificationCategory.violation => AppColors.dangerSoft,
      NotificationCategory.camera => AppColors.warningSoft,
      NotificationCategory.system => AppColors.blueSoft,
    };
    return StatusBadge(
      label: category.label,
      color: color,
      background: background,
      compact: compact,
    );
  }

  @override
  Widget build(BuildContext context) {
    final bg = background ?? color.withValues(alpha: 0.12);
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 11 : 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: compact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }
}
