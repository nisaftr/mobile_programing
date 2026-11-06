import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../models/statistics_model.dart';
import '../../providers/statistics_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/charts/vehicle_donut_chart.dart';
import '../../widgets/charts/violation_line_chart.dart';
import '../../widgets/section_header.dart';
import '../../widgets/state_views.dart';

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StatisticsProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<StatisticsProvider>();
    final data = provider.data;
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.blue,
        onRefresh: () => provider.load(refresh: true),
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: Responsive.pagePadding(context),
          children: [
            Text('Statistik', style: AppTypography.headline),
            const SizedBox(height: 2),
            Text(
              'Analisis tren pelanggaran dan komposisi kendaraan',
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: 18),
            if (provider.error != null && data == null)
              SizedBox(
                height: 380,
                child: AppErrorView(
                  message: provider.error!,
                  onRetry: () => provider.load(refresh: true),
                ),
              )
            else if (data == null)
              const _StatisticsSkeleton()
            else
              _StatisticsBody(data: data, provider: provider),
          ],
        ),
      ),
    );
  }
}

class _StatisticsBody extends StatelessWidget {
  const _StatisticsBody({required this.data, required this.provider});

  final StatisticsData data;
  final StatisticsProvider provider;

  @override
  Widget build(BuildContext context) {
    final chart = provider.activeChart;
    final periodTotal = chart.fold<double>(0, (sum, item) => sum + item.value);
    final peak = chart.isEmpty
        ? null
        : chart.reduce((a, b) => a.value >= b.value ? a : b);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _SummaryTile(
                label: 'Total Indikasi',
                value: '${data.totalDetected}',
                icon: Icons.center_focus_strong_rounded,
                color: AppColors.blue,
                softColor: AppColors.blueSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                label: 'Terverifikasi',
                value: '${data.verified}',
                icon: Icons.verified_rounded,
                color: AppColors.success,
                softColor: AppColors.successSoft,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _SummaryTile(
                label: 'Menunggu',
                value: '${data.pending}',
                icon: Icons.schedule_rounded,
                color: AppColors.warning,
                softColor: AppColors.warningSoft,
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        AppCard(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SectionHeader(
                      title: 'Tren Pelanggaran',
                      subtitle: 'Indikasi terdeteksi per periode',
                    ),
                  ),
                  _PeriodTotal(value: periodTotal.round()),
                ],
              ),
              const SizedBox(height: 14),
              _PeriodSelector(
                selected: provider.period,
                onChanged: provider.setPeriod,
              ),
              const SizedBox(height: 18),
              ViolationLineChart(points: chart, height: 190),
              if (peak != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(
                      Icons.insights_rounded,
                      size: 15,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Puncak pada ${peak.label} dengan '
                        '${peak.value.toInt()} indikasi.',
                        style: AppTypography.labelSmall,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Komposisi Kendaraan',
                subtitle: 'Perbandingan motor dan mobil',
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  VehicleDonutChart(
                    motorcycle: data.motorcycle,
                    car: data.car,
                    size: 150,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      children: [
                        _Legend(
                          color: AppColors.blue,
                          label: 'Motor',
                          value: data.motorcycle,
                          total: data.motorcycle + data.car,
                        ),
                        const SizedBox(height: 12),
                        _Legend(
                          color: AppColors.navy,
                          label: 'Mobil',
                          value: data.car,
                          total: data.motorcycle + data.car,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            children: [
              _BreakdownRow(
                label: 'Total pelanggaran',
                value: '${data.totalViolations}',
                color: AppColors.danger,
              ),
              const Divider(height: 20),
              _BreakdownRow(
                label: 'Terverifikasi',
                value: '${data.verified}',
                color: AppColors.success,
              ),
              const Divider(height: 20),
              _BreakdownRow(
                label: 'Menunggu verifikasi',
                value: '${data.pending}',
                color: AppColors.warning,
              ),
              const Divider(height: 20),
              _BreakdownRow(
                label: 'Rasio verifikasi',
                value: data.totalViolations == 0
                    ? '0%'
                    : '${(data.verified / data.totalViolations * 100).round()}%',
                color: AppColors.blue,
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Center(
          child: Text(
            'Data mock • diperbarui otomatis saat backend terhubung',
            style: AppTypography.labelSmall.copyWith(
              color: AppColors.textMuted,
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _SummaryTile extends StatelessWidget {
  const _SummaryTile({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.softColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final Color softColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.lgAll,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(color: softColor, shape: BoxShape.circle),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: AppTypography.headline.copyWith(fontSize: 22, color: color),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({required this.selected, required this.onChanged});

  final StatisticsPeriod selected;
  final ValueChanged<StatisticsPeriod> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: StatisticsPeriod.values.map((period) {
          final active = period == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(period),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.surface : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: AppColors.navy.withValues(alpha: 0.06),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                alignment: Alignment.center,
                child: Text(
                  period.label,
                  style: AppTypography.labelSmall.copyWith(
                    color: active ? AppColors.navy : AppColors.textSecondary,
                    fontWeight: active ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _PeriodTotal extends StatelessWidget {
  const _PeriodTotal({required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        '$value indikasi',
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.blue,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  const _Legend({
    required this.color,
    required this.label,
    required this.value,
    required this.total,
  });

  final Color color;
  final String label;
  final int value;
  final int total;

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (value / total * 100).round();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Text(
                label,
                style: AppTypography.caption.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text('$percent%', style: AppTypography.labelSmall),
          ],
        ),
        const SizedBox(height: 5),
        Text(
          '$value kendaraan',
          style: AppTypography.labelSmall.copyWith(color: AppColors.textMuted),
        ),
      ],
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label, style: AppTypography.caption)),
        Text(
          value,
          style: AppTypography.caption.copyWith(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class _StatisticsSkeleton extends StatelessWidget {
  const _StatisticsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : 10),
                child: const SkeletonBox(height: 104, radius: 14),
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const SkeletonBox(height: 320, radius: 16),
        const SizedBox(height: 16),
        const SkeletonBox(height: 210, radius: 16),
      ],
    );
  }
}
