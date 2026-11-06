import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../models/violation_model.dart';
import '../../providers/violation_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/state_views.dart';
import '../../widgets/violation_card.dart';

class ViolationListScreen extends StatefulWidget {
  const ViolationListScreen({super.key});

  @override
  State<ViolationListScreen> createState() => _ViolationListScreenState();
}

class _ViolationListScreenState extends State<ViolationListScreen> {
  final _searchController = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ViolationProvider>().load();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {});
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 420), () {
      if (mounted) context.read<ViolationProvider>().search(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ViolationProvider>();
    return SafeArea(
      child: RefreshIndicator(
        color: AppColors.blue,
        onRefresh: provider.refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: Responsive.pagePadding(context),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Data Pelanggaran', style: AppTypography.headline),
                      const SizedBox(height: 2),
                      Text(
                        '${provider.total} indikasi tercatat',
                        style: AppTypography.bodyMuted,
                      ),
                    ],
                  ),
                ),
                if (provider.hasActiveFilter)
                  TextButton.icon(
                    onPressed: () {
                      _searchController.clear();
                      provider.clearFilters();
                    },
                    icon: const Icon(Icons.filter_alt_off_rounded, size: 16),
                    label: const Text('Reset'),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              style: AppTypography.body,
              decoration: InputDecoration(
                hintText: 'Cari ID, plat, lokasi, atau kamera',
                prefixIcon: const Icon(Icons.search_rounded, size: 20),
                suffixIcon: _searchController.text.isEmpty
                    ? null
                    : IconButton(
                        tooltip: 'Hapus pencarian',
                        icon: const Icon(Icons.close_rounded, size: 18),
                        onPressed: () {
                          _searchController.clear();
                          provider.search('');
                          setState(() {});
                        },
                      ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _FilterChoice(
                    label: 'Semua',
                    selected: !provider.hasActiveFilter,
                    onTap: () {
                      _searchController.clear();
                      provider.clearFilters();
                      setState(() {});
                    },
                  ),
                  _FilterChoice(
                    label: 'Motor',
                    selected: provider.vehicleType == VehicleType.motorcycle,
                    onTap: () => provider.setVehicleType(
                      provider.vehicleType == VehicleType.motorcycle
                          ? null
                          : VehicleType.motorcycle,
                    ),
                  ),
                  _FilterChoice(
                    label: 'Mobil',
                    selected: provider.vehicleType == VehicleType.car,
                    onTap: () => provider.setVehicleType(
                      provider.vehicleType == VehicleType.car
                          ? null
                          : VehicleType.car,
                    ),
                  ),
                  _FilterChoice(
                    label: 'Menunggu',
                    selected: provider.status == ViolationStatus.pending,
                    onTap: () => provider.setStatus(
                      provider.status == ViolationStatus.pending
                          ? null
                          : ViolationStatus.pending,
                    ),
                  ),
                  _FilterChoice(
                    label: 'Terverifikasi',
                    selected: provider.status == ViolationStatus.verified,
                    onTap: () => provider.setStatus(
                      provider.status == ViolationStatus.verified
                          ? null
                          : ViolationStatus.verified,
                    ),
                  ),
                  _FilterChoice(
                    label: 'Tidak Valid',
                    selected: provider.status == ViolationStatus.invalid,
                    onTap: () => provider.setStatus(
                      provider.status == ViolationStatus.invalid
                          ? null
                          : ViolationStatus.invalid,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: ActionChip(
                      avatar: const Icon(
                        Icons.calendar_today_rounded,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      label: Text(
                        provider.date == null
                            ? 'Tanggal'
                            : DateFormatter.date(provider.date!),
                        style: AppTypography.labelSmall.copyWith(
                          color: provider.date == null
                              ? AppColors.textSecondary
                              : AppColors.blue,
                          fontWeight: provider.date == null
                              ? FontWeight.w500
                              : FontWeight.w600,
                        ),
                      ),
                      backgroundColor: provider.date == null
                          ? AppColors.surface
                          : AppColors.blueSoft,
                      side: BorderSide(
                        color: provider.date == null
                            ? AppColors.outline
                            : AppColors.blue.withValues(alpha: 0.4),
                      ),
                      onPressed: () => _pickDate(provider),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (provider.error != null && provider.items.isEmpty)
              SizedBox(
                height: 320,
                child: AppErrorView(
                  message: provider.error!,
                  onRetry: provider.load,
                ),
              )
            else if (provider.isLoading && provider.items.isEmpty)
              const ListSkeleton(count: 4)
            else if (provider.items.isEmpty)
              SizedBox(
                height: 340,
                child: EmptyView(
                  icon: Icons.search_off_rounded,
                  title: 'Data tidak ditemukan',
                  message: 'Tidak ada data pelanggaran yang sesuai dengan pencarian atau filter.',
                  actionLabel: provider.hasActiveFilter ? 'Reset Filter' : null,
                  onAction: provider.hasActiveFilter
                      ? () {
                          _searchController.clear();
                          provider.clearFilters();
                          setState(() {});
                        }
                      : null,
                ),
              )
            else
              ...provider.items.map(
                (violation) => ViolationCard(
                  violation: violation,
                  onTap: () => _openDetail(violation),
                ),
              ),
            if (provider.items.isNotEmpty) ...[
              const SizedBox(height: 4),
              if (provider.hasMore)
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: 'Muat Lebih Banyak',
                        variant: AppButtonVariant.secondary,
                        icon: Icons.expand_more_rounded,
                        isLoading: provider.isLoadingMore,
                        height: 46,
                        onPressed: provider.loadMore,
                      ),
                    ),
                  ],
                )
              else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Semua data telah ditampilkan',
                      style: AppTypography.labelSmall.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(ViolationProvider provider) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: provider.date ?? now,
      firstDate: DateTime(now.year - 2),
      lastDate: now,
      helpText: 'Filter tanggal kejadian',
      cancelText: 'Batal',
      confirmText: 'Pilih',
    );
    if (picked == null) return;
    if (provider.date != null &&
        provider.date!.year == picked.year &&
        provider.date!.month == picked.month &&
        provider.date!.day == picked.day) {
      provider.setDate(null);
    } else {
      provider.setDate(picked);
    }
  }

  void _openDetail(ViolationModel violation) {
    Navigator.of(context)
        .pushNamed(AppRoutes.violationDetail, arguments: violation)
        .then((_) {
          if (mounted) {
            context.read<ViolationProvider>().load(showLoading: false);
          }
        });
  }
}

class _FilterChoice extends StatelessWidget {
  const _FilterChoice({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        showCheckmark: false,
        onSelected: (_) => onTap(),
        labelStyle: AppTypography.labelSmall.copyWith(
          color: selected ? AppColors.blue : AppColors.textSecondary,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        ),
        backgroundColor: AppColors.surface,
        selectedColor: AppColors.blueSoft,
        side: BorderSide(
          color: selected
              ? AppColors.blue.withValues(alpha: 0.4)
              : AppColors.outline,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
      ),
    );
  }
}
