import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/date_formatter.dart';
import '../../core/utils/responsive.dart';
import '../../models/violation_model.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/violation_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/detection_preview.dart';
import '../../widgets/status_badge.dart';

class ViolationDetailScreen extends StatefulWidget {
  const ViolationDetailScreen({super.key, required this.violation});

  final ViolationModel violation;

  @override
  State<ViolationDetailScreen> createState() => _ViolationDetailScreenState();
}

class _ViolationDetailScreenState extends State<ViolationDetailScreen> {
  late ViolationModel _violation = widget.violation;
  bool _showDetection = true;
  bool _isSubmitting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pelanggaran'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: Responsive.pagePadding(context),
        children: [
          AppCard(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                DetectionPreview(
                  boxes: [
                    PreviewBox(
                      box: _violation.boundingBox,
                      label:
                          '${_violation.vehicleType.label} '
                          '${(_violation.confidence * 100).round()}%',
                      color: _violation.status == ViolationStatus.invalid
                          ? AppColors.textSecondary
                          : AppColors.warning,
                      isViolation: true,
                    ),
                  ],
                  showOverlay: _showDetection,
                  badge: _ImageBadge(
                    label: _showDetection ? 'HASIL DETEKSI' : 'FOTO ASLI',
                    color: _showDetection ? AppColors.blue : AppColors.navy,
                  ),
                  footer: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _violation.cameraName,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Text(
                        DateFormatter.time(_violation.occurredAt),
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _ToggleTab(
                          label: 'Foto Asli',
                          selected: !_showDetection,
                          onTap: () => setState(() => _showDetection = false),
                        ),
                      ),
                      Expanded(
                        child: _ToggleTab(
                          label: 'Hasil Deteksi',
                          selected: _showDetection,
                          onTap: () => setState(() => _showDetection = true),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_violation.id, style: AppTypography.title),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatter.dateTime(_violation.occurredAt),
                      style: AppTypography.bodyMuted,
                    ),
                  ],
                ),
              ),
              StatusBadge.violation(_violation.status),
            ],
          ),
          const SizedBox(height: 16),
          AppCard(
            child: Column(
              children: [
                _InfoRow(
                  icon: Icons.two_wheeler_rounded,
                  label: 'Jenis Kendaraan',
                  value: _violation.vehicleType.label,
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.pin_outlined,
                  label: 'Nomor Polisi',
                  value: _violation.plateNumber ?? 'Tidak tersedia',
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.place_outlined,
                  label: 'Lokasi',
                  value: _violation.location,
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.videocam_outlined,
                  label: 'Kamera',
                  value: _violation.cameraName,
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.speed_rounded,
                  label: 'Tingkat Keyakinan',
                  value: '${(_violation.confidence * 100).round()}%',
                ),
                const Divider(height: 20),
                _InfoRow(
                  icon: Icons.schedule_rounded,
                  label: 'Waktu Kejadian',
                  value: DateFormatter.dateTime(_violation.occurredAt),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (_violation.officerNote != null) ...[
            AppCard(
              color: AppColors.blueSoft,
              borderColor: AppColors.blue.withValues(alpha: 0.18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.sticky_note_2_outlined,
                        size: 16,
                        color: AppColors.blue,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Catatan Petugas',
                        style: AppTypography.label.copyWith(
                          color: AppColors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(_violation.officerNote!, style: AppTypography.body),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
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
                  Icons.gavel_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Hasil deteksi otomatis bukan penetapan pelanggaran hukum. '
                    'Petugas wajib memeriksa keaslian bukti sebelum memverifikasi.',
                    style: AppTypography.labelSmall.copyWith(height: 1.5),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
      bottomNavigationBar: _ActionBar(
        status: _violation.status,
        isLoading: _isSubmitting,
        onVerify: () => _verify(ViolationStatus.verified),
        onInvalid: () => _verify(ViolationStatus.invalid),
        onNote: () => _addNote(),
      ),
    );
  }

  Future<void> _verify(ViolationStatus status) async {
    final note = await _showNoteDialog(
      title: status == ViolationStatus.verified
          ? 'Verifikasi Pelanggaran'
          : 'Tandai Tidak Valid',
      confirmLabel: status == ViolationStatus.verified
          ? 'Verifikasi'
          : 'Tandai Tidak Valid',
      initialNote: _violation.officerNote,
      description: status == ViolationStatus.verified
          ? 'Pastikan bukti telah diperiksa. Data akan ditandai sebagai pelanggaran terverifikasi.'
          : 'Data akan ditandai tidak valid dan tidak dihitung sebagai pelanggaran.',
    );
    if (note == null || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      await context.read<ViolationProvider>().updateStatus(
        _violation.id,
        status,
        note: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      setState(() {
        _violation = _violation.copyWith(
          status: status,
          officerNote: note.isEmpty ? null : note,
        );
      });
      context.read<DashboardProvider>().load(refresh: true);
      _showSnackBar(
        status == ViolationStatus.verified
            ? 'Pelanggaran berhasil diverifikasi.'
            : 'Data ditandai sebagai tidak valid.',
      );
    } catch (_) {
      if (mounted) _showSnackBar('Gagal memperbarui status. Coba lagi.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _addNote() async {
    final note = await _showNoteDialog(
      title: 'Tambah Catatan',
      confirmLabel: 'Simpan Catatan',
      initialNote: _violation.officerNote,
      description: 'Catatan akan ditampilkan pada detail pelanggaran.',
    );
    if (note == null || !mounted) return;
    setState(() => _isSubmitting = true);
    try {
      await context.read<ViolationProvider>().updateStatus(
        _violation.id,
        _violation.status,
        note: note.isEmpty ? null : note,
      );
      if (!mounted) return;
      setState(() {
        _violation = _violation.copyWith(
          officerNote: note.isEmpty ? null : note,
        );
      });
      _showSnackBar('Catatan berhasil disimpan.');
    } catch (_) {
      if (mounted) _showSnackBar('Gagal menyimpan catatan.');
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<String?> _showNoteDialog({
    required String title,
    required String confirmLabel,
    required String description,
    String? initialNote,
  }) {
    final controller = TextEditingController(text: initialNote);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTypography.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(description, style: AppTypography.bodyMuted),
            const SizedBox(height: 14),
            TextField(
              controller: controller,
              maxLines: 4,
              minLines: 2,
              style: AppTypography.body,
              decoration: const InputDecoration(
                hintText: 'Catatan petugas (opsional)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(confirmLabel),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ActionBar extends StatelessWidget {
  const _ActionBar({
    required this.status,
    required this.isLoading,
    required this.onVerify,
    required this.onInvalid,
    required this.onNote,
  });

  final ViolationStatus status;
  final bool isLoading;
  final VoidCallback onVerify;
  final VoidCallback onInvalid;
  final VoidCallback onNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.outline)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Tidak Valid',
                    variant: AppButtonVariant.secondary,
                    icon: Icons.close_rounded,
                    height: 46,
                    onPressed: isLoading ? null : onInvalid,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AppButton(
                    label: status == ViolationStatus.verified
                        ? 'Verifikasi Ulang'
                        : 'Verifikasi',
                    icon: Icons.verified_rounded,
                    height: 46,
                    isLoading: isLoading,
                    onPressed: isLoading ? null : onVerify,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextButton.icon(
              onPressed: isLoading ? null : onNote,
              icon: const Icon(Icons.edit_note_rounded, size: 18),
              label: const Text('Tambah Catatan'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ImageBadge extends StatelessWidget {
  const _ImageBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: Colors.white,
          fontSize: 9,
          letterSpacing: 0.7,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: selected
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
          label,
          style: AppTypography.labelSmall.copyWith(
            color: selected ? AppColors.navy : AppColors.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.textMuted),
        const SizedBox(width: 10),
        SizedBox(width: 120, child: Text(label, style: AppTypography.caption)),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
