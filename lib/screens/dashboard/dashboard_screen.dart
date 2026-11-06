import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../models/camera_status_model.dart';
import '../../models/statistics_model.dart';
import '../../models/violation_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/notification_provider.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_card.dart';
import '../../widgets/charts/violation_line_chart.dart';
import '../../widgets/section_header.dart';
import '../../widgets/stat_card.dart';
import '../../widgets/state_views.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/violation_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dashboard = context.watch<DashboardProvider>();
    final user = context.watch<AppProvider>().user;
    final unread = context.watch<NotificationProvider>().unreadCount;

    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.blue,
        onRefresh: () => dashboard.load(refresh: true),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: Responsive.pagePadding(context).copyWith(bottom: 0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _Header(
                    name: user?.name ?? 'Petugas ETLE',
                    initials: user?.initials ?? 'PE',
                    unread: unread,
                    onNotificationTap: _openNotifications,
                  ),
                  const SizedBox(height: 20),
                  if (dashboard.error != null && dashboard.data == null)
                    SizedBox(
                      height: 360,
                      child: AppErrorView(
                        message: dashboard.error!,
                        onRetry: dashboard.load,
                      ),
                    )
                  else if (dashboard.data == null)
                    const _DashboardSkeleton()
                  else
                    _DashboardContent(
                      data: dashboard.data!,
                      onSeeAll: () => context.read<AppProvider>().setTab(2),
                      onOpenViolation: _openViolation,
                    ),
                  const SizedBox(height: 24),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).pushNamed(AppRoutes.notifications).then((_) {
      if (mounted) {
        context.read<NotificationProvider>().load(refresh: true);
      }
    });
  }

  void _openViolation(ViolationModel violation) {
    Navigator.of(context)
        .pushNamed(AppRoutes.violationDetail, arguments: violation)
        .then((_) {
          if (mounted) {
            context.read<DashboardProvider>().load(refresh: true);
          }
        });
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.name,
    required this.initials,
    required this.unread,
    required this.onNotificationTap,
  });

  final String name;
  final String initials;
  final int unread;
  final VoidCallback onNotificationTap;

  @override
  Widget build(BuildContext context) {
    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat pagi'
        : hour < 15
        ? 'Selamat siang'
        : hour < 19
        ? 'Selamat sore'
        : 'Selamat malam';
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('$greeting,', style: AppTypography.bodyMuted),
              const SizedBox(height: 2),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.headline.copyWith(fontSize: 22),
              ),
              const SizedBox(height: 3),
              Text(
                DateFormatter.day(DateTime.now()),
                style: AppTypography.caption,
              ),
            ],
          ),
        ),
        Stack(
          clipBehavior: Clip.none,
          children: [
            Material(
              color: AppColors.surface,
              shape: const CircleBorder(
                side: BorderSide(color: AppColors.outline),
              ),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onNotificationTap,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(
                    Icons.notifications_none_rounded,
                    color: AppColors.navy,
                    size: 22,
                  ),
                ),
              ),
            ),
            if (unread > 0)
              Positioned(
                right: -1,
                top: -2,
                child: Container(
                  constraints: const BoxConstraints(minWidth: 17),
                  height: 17,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: AppColors.danger,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: AppColors.background, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unread > 9 ? '9+' : '$unread',
                    style: AppTypography.labelSmall.copyWith(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 10),
        AppAvatar(initials: initials),
      ],
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({
    required this.data,
    required this.onSeeAll,
    required this.onOpenViolation,
  });

  final DashboardData data;
  final VoidCallback onSeeAll;
  final ValueChanged<ViolationModel> onOpenViolation;

  @override
  Widget build(BuildContext context) {
    final onlineCameras = data.cameras.where((item) => item.isOnline).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SystemStatusCard(
          serverOnline: data.serverOnline,
          onlineCameras: onlineCameras,
          totalCameras: data.cameras.length,
        ),
        const SizedBox(height: 20),
        SectionHeader(
          title: 'Ringkasan Hari Ini',
          subtitle: 'Data indikasi pelanggaran jalur busway',
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = Responsive.statColumns(context);
            final spacing = 12.0;
            final width =
                (constraints.maxWidth - spacing * (columns - 1)) / columns;
            final cards = [
              StatCard(
                label: 'Total Pelanggaran',
                value: '${data.totalViolations}',
                icon: Icons.gavel_rounded,
                accent: AppColors.navy,
                caption: '${data.verifiedCount} terverifikasi',
              ),
              StatCard(
                label: 'Pelanggaran Hari Ini',
                value: '${data.todayViolations}',
                icon: Icons.today_rounded,
                accent: AppColors.blue,
                caption: '${data.pendingCount} menunggu',
              ),
              StatCard(
                label: 'Kendaraan Motor',
                value: '${data.motorcycleCount}',
                icon: Icons.two_wheeler_rounded,
                accent: AppColors.warning,
              ),
              StatCard(
                label: 'Kendaraan Mobil',
                value: '${data.carCount}',
                icon: Icons.directions_car_rounded,
                accent: AppColors.success,
              ),
            ];
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: cards
                  .map((card) => SizedBox(width: width, child: card))
                  .toList(),
            );
          },
        ),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Tren Pelanggaran',
          subtitle: 'Tujuh hari terakhir',
          actionLabel: 'Statistik',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.fromLTRB(8, 18, 16, 10),
          child: ViolationLineChart(points: data.weeklyTrend),
        ),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Status Kamera',
          subtitle: '$onlineCameras dari ${data.cameras.length} kamera aktif',
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: List.generate(data.cameras.length, (index) {
              final camera = data.cameras[index];
              return _CameraRow(
                camera: camera,
                showDivider: index != data.cameras.length - 1,
              );
            }),
          ),
        ),
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Aktivitas Terbaru',
          subtitle: 'Indikasi pelanggaran terakhir',
          actionLabel: 'Lihat semua',
          onAction: onSeeAll,
        ),
        const SizedBox(height: 10),
        if (data.recentViolations.isEmpty)
          const AppCard(
            child: EmptyView(
              title: 'Belum ada aktivitas',
              message: 'Data pelanggaran akan muncul di sini.',
            ),
          )
        else
          ...data.recentViolations.map(
            (violation) => ViolationCard(
              violation: violation,
              onTap: () => onOpenViolation(violation),
            ),
          ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceAlt,
            borderRadius: AppRadius.mdAll,
            border: Border.all(color: AppColors.outline),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: AppColors.textSecondary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Semua indikasi pelanggaran wajib melalui proses verifikasi petugas sebelum dinyatakan valid.',
                  style: AppTypography.labelSmall.copyWith(height: 1.5),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SystemStatusCard extends StatelessWidget {
  const _SystemStatusCard({
    required this.serverOnline,
    required this.onlineCameras,
    required this.totalCameras,
  });

  final bool serverOnline;
  final int onlineCameras;
  final int totalCameras;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: _StatusItem(
              icon: Icons.dns_rounded,
              label: 'Server',
              value: serverOnline ? 'Online' : 'Offline',
              color: serverOnline ? AppColors.success : AppColors.danger,
            ),
          ),
          Container(width: 1, height: 34, color: AppColors.outline),
          Expanded(
            child: _StatusItem(
              icon: Icons.videocam_rounded,
              label: 'Kamera',
              value: '$onlineCameras / $totalCameras aktif',
              color: onlineCameras == totalCameras
                  ? AppColors.success
                  : AppColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusItem extends StatelessWidget {
  const _StatusItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: AppTypography.labelSmall),
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: Text(
                      value,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _CameraRow extends StatelessWidget {
  const _CameraRow({required this.camera, required this.showDivider});

  final CameraStatusModel camera;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final color = camera.isOnline ? AppColors.success : AppColors.danger;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          child: Row(
            children: [
              Icon(
                camera.isOnline
                    ? Icons.videocam_rounded
                    : Icons.videocam_off_rounded,
                size: 18,
                color: color,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      camera.name,
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(camera.location, style: AppTypography.labelSmall),
                  ],
                ),
              ),
              StatusBadge(
                label: camera.isOnline ? 'Aktif' : 'Offline',
                color: color,
                compact: true,
              ),
            ],
          ),
        ),
        if (showDivider) const Divider(height: 1, indent: 16, endIndent: 16),
      ],
    );
  }
}

class _DashboardSkeleton extends StatelessWidget {
  const _DashboardSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SkeletonBox(height: 68, radius: 14),
        const SizedBox(height: 20),
        const SkeletonBox(width: 160, height: 16),
        const SizedBox(height: 14),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: List.generate(
            4,
            (index) => const SizedBox(
              width: 160,
              child: SkeletonBox(height: 140, radius: 16),
            ),
          ),
        ),
        const SizedBox(height: 24),
        const SkeletonBox(width: 140, height: 16),
        const SizedBox(height: 12),
        const SkeletonBox(height: 200, radius: 16),
        const SizedBox(height: 24),
        const ListSkeleton(count: 2),
      ],
    );
  }
}
