import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../models/notification_model.dart';
import '../../providers/app_provider.dart';
import '../../providers/notification_provider.dart';
import '../../providers/violation_provider.dart';
import '../../widgets/state_views.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<NotificationProvider>();
      if (provider.items.isEmpty) provider.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          if (provider.unreadCount > 0)
            TextButton(
              onPressed: () => _markAllRead(provider),
              child: const Text('Tandai semua'),
            ),
          const SizedBox(width: 4),
        ],
      ),
      body: RefreshIndicator(
        color: AppColors.blue,
        onRefresh: () => provider.load(refresh: true),
        child: _buildBody(context, provider),
      ),
    );
  }

  Widget _buildBody(BuildContext context, NotificationProvider provider) {
    if (provider.error != null && provider.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: Responsive.pagePadding(context),
        children: [
          SizedBox(
            height: 420,
            child: AppErrorView(
              message: provider.error!,
              onRetry: () => provider.load(refresh: true),
            ),
          ),
        ],
      );
    }
    if (provider.isLoading && provider.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: Responsive.pagePadding(context),
        children: const [ListSkeleton(count: 4)],
      );
    }
    if (provider.items.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: Responsive.pagePadding(context),
        children: const [
          SizedBox(
            height: 460,
            child: EmptyView(
              icon: Icons.notifications_off_rounded,
              title: 'Tidak ada notifikasi',
              message: 'Pemberitahuan terbaru akan muncul di halaman ini.',
            ),
          ),
        ],
      );
    }

    final groups = _groupNotifications(provider.items);
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: Responsive.pagePadding(context),
      children: [
        if (provider.unreadCount > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${provider.unreadCount} notifikasi belum dibaca',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.blue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        for (final entry in groups.entries) ...[
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 8),
            child: Text(
              entry.key,
              style: AppTypography.label.copyWith(
                color: AppColors.textMuted,
                letterSpacing: 0.3,
              ),
            ),
          ),
          ...entry.value.map(
            (item) => _NotificationTile(
              notification: item,
              onTap: () => _openNotification(provider, item),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Map<String, List<NotificationModel>> _groupNotifications(
    List<NotificationModel> items,
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final groups = <String, List<NotificationModel>>{};
    for (final item in items) {
      final day = DateTime(
        item.createdAt.year,
        item.createdAt.month,
        item.createdAt.day,
      );
      final label = day == today
          ? 'Hari ini'
          : day == yesterday
          ? 'Kemarin'
          : DateFormatter.date(item.createdAt);
      groups.putIfAbsent(label, () => []).add(item);
    }
    return groups;
  }

  Future<void> _markAllRead(NotificationProvider provider) async {
    try {
      await provider.markAllRead();
      if (mounted) _showSnackBar('Semua notifikasi ditandai sudah dibaca.');
    } catch (_) {
      if (mounted) _showSnackBar('Gagal menandai notifikasi.');
    }
  }

  Future<void> _openNotification(
    NotificationProvider provider,
    NotificationModel item,
  ) async {
    if (!item.isRead) {
      try {
        await provider.markRead(item.id);
      } catch (_) {
        if (mounted) _showSnackBar('Gagal memperbarui notifikasi.');
      }
    }
    if (!mounted) return;
    if (item.violationId == null) return;

    final violations = context.read<ViolationProvider>();
    final app = context.read<AppProvider>();
    Navigator.of(context).pop();
    violations.search(item.violationId!);
    app.setTab(2);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.notification, required this.onTap});

  final NotificationModel notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _categoryStyle(notification.category);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: notification.isRead ? AppColors.surface : AppColors.blueSoft,
        borderRadius: AppRadius.lgAll,
        child: InkWell(
          borderRadius: AppRadius.lgAll,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgAll,
              border: Border.all(
                color: notification.isRead
                    ? AppColors.outline
                    : AppColors.blue.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: style.background,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(style.icon, size: 18, color: style.color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              notification.title,
                              style: AppTypography.caption.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: notification.isRead
                                    ? FontWeight.w600
                                    : FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormatter.relative(notification.createdAt),
                            style: AppTypography.labelSmall.copyWith(
                              color: notification.isRead
                                  ? AppColors.textMuted
                                  : AppColors.blue,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification.message,
                        style: AppTypography.labelSmall.copyWith(
                          height: 1.5,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: style.background,
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: Text(
                              notification.category.label,
                              style: AppTypography.labelSmall.copyWith(
                                color: style.color,
                                fontSize: 9,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (!notification.isRead) ...[
                            const SizedBox(width: 8),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: AppColors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
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

  _CategoryStyle _categoryStyle(NotificationCategory category) {
    return switch (category) {
      NotificationCategory.violation => const _CategoryStyle(
        icon: Icons.gavel_rounded,
        color: AppColors.danger,
        background: AppColors.dangerSoft,
      ),
      NotificationCategory.camera => const _CategoryStyle(
        icon: Icons.videocam_off_rounded,
        color: AppColors.warning,
        background: AppColors.warningSoft,
      ),
      NotificationCategory.system => const _CategoryStyle(
        icon: Icons.settings_suggest_rounded,
        color: AppColors.blue,
        background: AppColors.blueSoft,
      ),
    };
  }
}

class _CategoryStyle {
  const _CategoryStyle({
    required this.icon,
    required this.color,
    required this.background,
  });

  final IconData icon;
  final Color color;
  final Color background;
}
