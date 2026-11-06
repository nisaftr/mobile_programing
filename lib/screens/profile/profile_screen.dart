import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_radius.dart';
import '../../core/constants/app_strings.dart';
import '../../core/routes/app_routes.dart';
import '../../core/theme/app_typography.dart';
import '../../core/utils/responsive.dart';
import '../../core/utils/validators.dart';
import '../../models/user_model.dart';
import '../../providers/app_provider.dart';
import '../../services/service_exception.dart';
import '../../widgets/app_avatar.dart';
import '../../widgets/app_card.dart';
import '../../widgets/app_logo.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/section_header.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final user = app.user;
    return SafeArea(
      child: ListView(
        padding: Responsive.pagePadding(context),
        children: [
          Text('Profil', style: AppTypography.headline),
          const SizedBox(height: 2),
          Text(
            'Kelola akun dan preferensi aplikasi',
            style: AppTypography.bodyMuted,
          ),
          const SizedBox(height: 18),
          if (user == null)
            const AppCard(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('Data pengguna tidak tersedia.')),
              ),
            )
          else ...[
            _ProfileHeader(user: user),
            const SizedBox(height: 22),
            const SectionHeader(
              title: 'Akun',
              subtitle: 'Informasi dan keamanan akun',
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profil',
                    subtitle: 'Perbarui nama dan email',
                    onTap: () => _showEditProfile(context, user),
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Ubah Password',
                    subtitle: 'Ganti kata sandi akun',
                    onTap: () => _showChangePassword(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            const SectionHeader(
              title: 'Aplikasi',
              subtitle: 'Informasi dan dukungan',
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  _MenuTile(
                    icon: Icons.info_outline_rounded,
                    title: 'Tentang Aplikasi',
                    subtitle: 'Versi dan deskripsi sistem',
                    onTap: () => _showAbout(context),
                  ),
                  const Divider(height: 1, indent: 56),
                  _MenuTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Pusat Bantuan',
                    subtitle: 'Panduan penggunaan singkat',
                    onTap: () => _showHelp(context),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            AppCard(
              color: AppColors.dangerSoft,
              borderColor: AppColors.danger.withValues(alpha: 0.2),
              padding: EdgeInsets.zero,
              child: _MenuTile(
                icon: Icons.logout_rounded,
                title: 'Keluar',
                subtitle: 'Akhiri sesi petugas saat ini',
                color: AppColors.danger,
                onTap: () => _confirmLogout(context),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  const AppLogo(size: 40),
                  const SizedBox(height: 8),
                  Text(
                    '${AppStrings.appName} • v1.0.0',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Mode demo • data mock',
                    style: AppTypography.labelSmall.copyWith(
                      color: AppColors.textMuted,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ],
      ),
    );
  }

  Future<void> _showEditProfile(BuildContext context, UserModel user) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: user.name);
    final emailController = TextEditingController(text: user.email);
    return showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Edit Profil', style: AppTypography.title),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                label: 'Nama Lengkap',
                controller: nameController,
                hint: 'Nama petugas',
                prefixIcon: Icons.person_outline_rounded,
                validator: (value) => Validators.required(value, 'Nama'),
              ),
              const SizedBox(height: 14),
              AppTextField(
                label: 'Email',
                controller: emailController,
                hint: 'nama@etle.id',
                prefixIcon: Icons.mail_outline_rounded,
                keyboardType: TextInputType.emailAddress,
                validator: Validators.email,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () {
              if (!(formKey.currentState?.validate() ?? false)) return;
              context.read<AppProvider>().updateProfile(
                name: nameController.text.trim(),
                email: emailController.text.trim(),
              );
              Navigator.pop(dialogContext);
              _showSnackBar(context, 'Profil berhasil diperbarui.');
            },
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }

  Future<void> _showChangePassword(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final currentController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    var isLoading = false;

    return showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setState) => AlertDialog(
          title: Text('Ubah Password', style: AppTypography.title),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Password Saat Ini',
                  controller: currentController,
                  obscureText: true,
                  prefixIcon: Icons.lock_outline_rounded,
                  validator: (value) =>
                      Validators.required(value, 'Password saat ini'),
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Password Baru',
                  controller: newController,
                  obscureText: true,
                  prefixIcon: Icons.lock_reset_rounded,
                  validator: Validators.newPassword,
                ),
                const SizedBox(height: 14),
                AppTextField(
                  label: 'Konfirmasi Password',
                  controller: confirmController,
                  obscureText: true,
                  prefixIcon: Icons.check_circle_outline_rounded,
                  validator: (value) =>
                      Validators.confirmPassword(value, newController.text),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: isLoading
                  ? null
                  : () async {
                      if (!(formKey.currentState?.validate() ?? false)) return;
                      setState(() => isLoading = true);
                      try {
                        await context.read<AppProvider>().changePassword(
                          currentPassword: currentController.text,
                          newPassword: newController.text,
                        );
                        if (!dialogContext.mounted) return;
                        Navigator.pop(dialogContext);
                        _showSnackBar(context, 'Password berhasil diubah.');
                      } on AuthException catch (error) {
                        setState(() => isLoading = false);
                        _showSnackBar(context, error.message);
                      } catch (_) {
                        setState(() => isLoading = false);
                        _showSnackBar(
                          context,
                          'Gagal mengubah password. Coba lagi.',
                        );
                      }
                    },
              child: isLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showAbout(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const AppLogo(size: 64),
            const SizedBox(height: 12),
            Text(AppStrings.appName, style: AppTypography.title),
            const SizedBox(height: 2),
            Text(AppStrings.tagline, style: AppTypography.bodyMuted),
            const SizedBox(height: 14),
            Text(
              'Aplikasi pemantauan pelanggaran jalur busway berbasis computer '
              'vision. Sistem mendeteksi kendaraan, memeriksa area jalur '
              'busway, dan menampilkan indikasi untuk diverifikasi petugas.',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(height: 1.6),
            ),
            const SizedBox(height: 16),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: const [
                _FeaturePill(label: 'Deteksi Real-time'),
                _FeaturePill(label: 'Verifikasi Petugas'),
                _FeaturePill(label: 'Statistik'),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'Versi 1.0.0 • Build demo',
              style: AppTypography.labelSmall.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHelp(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      builder: (context) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Pusat Bantuan', style: AppTypography.title),
            const SizedBox(height: 4),
            Text(
              'Panduan singkat penggunaan aplikasi',
              style: AppTypography.bodyMuted,
            ),
            const SizedBox(height: 16),
            const _HelpItem(
              icon: Icons.dashboard_outlined,
              title: 'Dashboard',
              description:
                  'Ringkasan pelanggaran, tren mingguan, status kamera, dan '
                  'aktivitas terbaru.',
            ),
            const _HelpItem(
              icon: Icons.videocam_outlined,
              title: 'Live Monitoring',
              description:
                  'Pilih kamera untuk melihat deteksi kendaraan. Kotak merah '
                  'menandakan indikasi kendaraan di jalur busway.',
            ),
            const _HelpItem(
              icon: Icons.gavel_outlined,
              title: 'Data Pelanggaran',
              description:
                  'Cari dan filter data. Buka detail untuk memverifikasi atau '
                  'menandai data tidak valid disertai catatan.',
            ),
            const _HelpItem(
              icon: Icons.bar_chart_rounded,
              title: 'Statistik',
              description:
                  'Analisis tren harian, mingguan, dan bulanan serta komposisi '
                  'jenis kendaraan.',
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warningSoft,
                borderRadius: AppRadius.mdAll,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    size: 16,
                    color: AppColors.warning,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Versi demo menggunakan data mock dan tidak terhubung '
                      'ke kamera nyata.',
                      style: AppTypography.labelSmall.copyWith(height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Keluar dari aplikasi?', style: AppTypography.title),
        content: Text(
          'Sesi petugas akan diakhiri dan Anda perlu login kembali.',
          style: AppTypography.bodyMuted,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;
    final app = context.read<AppProvider>();
    await app.logout();
    if (!context.mounted) return;
    Navigator.of(
      context,
      rootNavigator: true,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navy, AppColors.navyDark],
        ),
        borderRadius: AppRadius.lgAll,
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              AppAvatar(
                initials: user.initials,
                size: 58,
                backgroundColor: Colors.white.withValues(alpha: 0.14),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.title.copyWith(
                        color: Colors.white,
                        fontSize: 19,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.email,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.72),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        user.role,
                        style: AppTypography.labelSmall.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(height: 1, color: Colors.white.withValues(alpha: 0.1)),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.badge_outlined, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                'ID Petugas',
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white.withValues(alpha: 0.65),
                ),
              ),
              const Spacer(),
              Text(
                user.id,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.navy,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.lgAll,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.09),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 17, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.caption.copyWith(
                      color: color == AppColors.danger
                          ? AppColors.danger
                          : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(subtitle, style: AppTypography.labelSmall),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: color == AppColors.danger
                  ? AppColors.danger
                  : AppColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.blueSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        label,
        style: AppTypography.labelSmall.copyWith(
          color: AppColors.blue,
          fontWeight: FontWeight.w600,
          fontSize: 10,
        ),
      ),
    );
  }
}

class _HelpItem extends StatelessWidget {
  const _HelpItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: AppColors.blueSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 16, color: AppColors.blue),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTypography.labelSmall.copyWith(height: 1.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
