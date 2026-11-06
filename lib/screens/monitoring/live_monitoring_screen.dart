import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../models/camera_status_model.dart';
import '../../models/detection_model.dart';
import '../../models/violation_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/monitoring_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detection_preview.dart';
import '../../widgets/state_views.dart';

class LiveMonitoringScreen extends StatefulWidget {
  const LiveMonitoringScreen({super.key, this.active = true});

  final bool active;

  @override
  State<LiveMonitoringScreen> createState() => _LiveMonitoringScreenState();
}

class _LiveMonitoringScreenState extends State<LiveMonitoringScreen> {
  late final MonitoringProvider _monitoring;

  @override
  void initState() {
    super.initState();
    _monitoring = context.read<MonitoringProvider>();
    if (widget.active) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _monitoring.start());
    }
  }

  @override
  void didUpdateWidget(covariant LiveMonitoringScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.active == oldWidget.active) return;
    if (widget.active) {
      _monitoring.start();
    } else {
      _monitoring.stop();
    }
  }

  @override
  void dispose() {
    _monitoring.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<MonitoringProvider>();
    final snapshot = provider.snapshot;
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.blue,
        onRefresh: provider.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: Responsive.pagePadding(context),
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Live Monitoring', style: AppTypography.headline),
                      const SizedBox(height: 2),
                      Text(
                        'Pemrosesan OpenCV • MOG2 + Morfologi',
                        style: AppTypography.bodyMuted,
                      ),
                    ],
                  ),
                ),
                _ConnectionPill(
                  online: snapshot?.isOnline ?? false,
                  loading: snapshot == null && provider.isLoading,
                ),
              ],
            ),
            const SizedBox(height: 18),
            if (provider.cameras.isNotEmpty) ...[
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: provider.cameras.length,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final camera = provider.cameras[index];
                    return _CameraChip(
                      camera: camera,
                      selected: camera.id == provider.selectedCameraId,
                      onTap: () => provider.selectCamera(camera.id),
                    );
                  },
                ),
              ),
              const SizedBox(height: 14),
            ],
            if (provider.error != null && snapshot == null)
              SizedBox(
                height: 340,
                child: AppErrorView(
                  message: provider.error!,
                  onRetry: provider.refresh,
                ),
              )
            else if (snapshot == null)
              const _PreviewSkeleton()
            else
              _MonitoringContent(
                snapshot: snapshot,
                onOpenData: () => context.read<AppProvider>().setTab(2),
              ),
          ],
        ),
      ),
    );
  }
}

class _ConnectionPill extends StatelessWidget {
  const _ConnectionPill({required this.online, required this.loading});

  final bool online;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final color = loading
        ? AppColors.warning
        : online
        ? AppColors.success
        : AppColors.danger;
    final label = loading
        ? 'Menghubungkan'
        : online
        ? 'Terhubung'
        : 'Offline';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _CameraChip extends StatelessWidget {
  const _CameraChip({
    required this.camera,
    required this.selected,
    required this.onTap,
  });

  final CameraStatusModel camera;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = camera.isOnline ? AppColors.success : AppColors.danger;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.navy : AppColors.surface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? AppColors.navy : AppColors.outline,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 6),
            Text(
              camera.name.replaceFirst('Kamera ', ''),
              style: AppTypography.labelSmall.copyWith(
                color: selected ? Colors.white : AppColors.textSecondary,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonitoringContent extends StatelessWidget {
  const _MonitoringContent({required this.snapshot, required this.onOpenData});

  final MonitoringSnapshot snapshot;
  final VoidCallback onOpenData;

  @override
  Widget build(BuildContext context) {
    final boxes = snapshot.detections
        .map(
          (item) => PreviewBox(
            box: item.boundingBox,
            label:
                '${item.vehicleType.label} '
                '${(item.confidence * 100).round()}%',
            color: item.isInBusway ? AppColors.danger : AppColors.success,
            isViolation: item.isInBusway,
          ),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        DetectionPreview(
          boxes: snapshot.isOnline ? boxes : const [],
          badge: _LiveBadge(online: snapshot.isOnline),
          footer: Row(
            children: [
              Expanded(
                child: Text(
                  snapshot.cameraName,
                  overflow: TextOverflow.ellipsis,
                  style: AppTypography.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                '${snapshot.fps} FPS • ${DateFormatter.time(snapshot.updatedAt)}',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.8),
                ),
              ),
            ],
          ),
        ),
        if (!snapshot.isOnline) ...[
          const SizedBox(height: 12),
          _OfflineBanner(cameraName: snapshot.cameraName),
        ] else if (snapshot.hasViolationAlert) ...[
          const SizedBox(height: 12),
          _ViolationAlert(
            message:
                snapshot.violationMessage ??
                'Indikasi kendaraan memasuki jalur busway.',
            onOpenData: onOpenData,
          ),
        ],
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _MiniMetric(
                label: 'Terdeteksi',
                value: '${snapshot.detections.length}',
                icon: Icons.center_focus_strong_rounded,
                color: AppColors.blue,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniMetric(
                label: 'Motor',
                value: '${snapshot.motorcycleCount}',
                icon: Icons.two_wheeler_rounded,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniMetric(
                label: 'Mobil',
                value: '${snapshot.carCount}',
                icon: Icons.directions_car_rounded,
                color: AppColors.success,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _MiniMetric(
                label: 'Busway',
                value:
                    '${snapshot.detections.where((e) => e.isInBusway).length}',
                icon: Icons.warning_amber_rounded,
                color: AppColors.danger,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        AppCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: AppColors.blueSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.memory_rounded,
                  size: 18,
                  color: AppColors.blue,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Mode demo computer vision',
                      style: AppTypography.label.copyWith(
                        color: AppColors.navy,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Bounding box dan data kendaraan berasal dari mock service. '
                      'Stream CCTV nyata dihubungkan pada Tahap 6.',
                      style: AppTypography.labelSmall.copyWith(height: 1.5),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'ROI jalur busway ditandai area kuning. Kendaraan di area tersebut '
          'merupakan indikasi awal dan belum tentu pelanggaran sah.',
          style: AppTypography.labelSmall.copyWith(
            height: 1.5,
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _LiveBadge extends StatelessWidget {
  const _LiveBadge({required this.online});

  final bool online;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: (online ? AppColors.danger : AppColors.textSecondary).withValues(
          alpha: 0.9,
        ),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            online ? 'LIVE' : 'OFFLINE',
            style: AppTypography.labelSmall.copyWith(
              color: Colors.white,
              fontSize: 9,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

class _ViolationAlert extends StatelessWidget {
  const _ViolationAlert({required this.message, required this.onOpenData});

  final String message;
  final VoidCallback onOpenData;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: AppTypography.caption.copyWith(
                color: AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: onOpenData,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.danger,
              padding: const EdgeInsets.symmetric(horizontal: 6),
              minimumSize: const Size(0, 32),
            ),
            child: const Text('Lihat'),
          ),
        ],
      ),
    );
  }
}

class _OfflineBanner extends StatelessWidget {
  const _OfflineBanner({required this.cameraName});

  final String cameraName;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.dangerSoft,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.videocam_off_rounded,
            color: AppColors.danger,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$cameraName sedang offline. Tidak ada data yang diterima.',
              style: AppTypography.caption.copyWith(color: AppColors.danger),
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniMetric extends StatelessWidget {
  const _MiniMetric({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.mdAll,
        border: Border.all(color: AppColors.outline),
      ),
      child: Column(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 6),
          Text(value, style: AppTypography.title.copyWith(fontSize: 16)),
          const SizedBox(height: 1),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.labelSmall.copyWith(fontSize: 9.5),
          ),
        ],
      ),
    );
  }
}

class _PreviewSkeleton extends StatelessWidget {
  const _PreviewSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const AspectRatio(
          aspectRatio: 16 / 9,
          child: SkeletonBox(height: double.infinity, radius: 16),
        ),
        const SizedBox(height: 16),
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 3 ? 0 : 8),
                child: const SkeletonBox(height: 78, radius: 12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const SkeletonBox(height: 70, radius: 14),
      ],
    );
  }
}
