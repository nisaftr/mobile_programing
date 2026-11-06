import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/theme/app_typography.dart';

class VehicleDonutChart extends StatelessWidget {
  const VehicleDonutChart({
    super.key,
    required this.motorcycle,
    required this.car,
    this.size = 180,
  });

  final int motorcycle;
  final int car;
  final double size;

  @override
  Widget build(BuildContext context) {
    final total = motorcycle + car;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 3,
              centerSpaceRadius: size * 0.29,
              startDegreeOffset: -90,
              pieTouchData: PieTouchData(enabled: false),
              sections: [
                PieChartSectionData(
                  value: motorcycle.toDouble(),
                  color: AppColors.blue,
                  radius: size * 0.12,
                  showTitle: false,
                ),
                PieChartSectionData(
                  value: car.toDouble(),
                  color: AppColors.navy,
                  radius: size * 0.12,
                  showTitle: false,
                ),
                if (total == 0)
                  PieChartSectionData(
                    value: 1,
                    color: AppColors.outline,
                    radius: size * 0.12,
                    showTitle: false,
                  ),
              ],
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$total',
                style: AppTypography.headline.copyWith(fontSize: 24),
              ),
              Text('Kendaraan', style: AppTypography.labelSmall),
            ],
          ),
        ],
      ),
    );
  }
}
