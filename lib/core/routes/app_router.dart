import 'package:flutter/material.dart';

import '../../models/violation_model.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/main_shell.dart';
import '../../screens/notifications/notification_screen.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/violations/violation_detail_screen.dart';
import 'app_routes.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case AppRoutes.splash:
        return _page(const SplashScreen(), settings);
      case AppRoutes.login:
        return _page(const LoginScreen(), settings);
      case AppRoutes.main:
        return _page(const MainShell(), settings);
      case AppRoutes.notifications:
        return _page(const NotificationScreen(), settings);
      case AppRoutes.violationDetail:
        final argument = settings.arguments;
        if (argument is ViolationModel) {
          return _page(ViolationDetailScreen(violation: argument), settings);
        }
        return _page(const _MissingArgumentScreen(), settings);
      default:
        return _page(const _UnknownRouteScreen(), settings);
    }
  }

  static PageRouteBuilder<dynamic> _page(Widget child, RouteSettings settings) {
    return PageRouteBuilder<dynamic>(
      settings: settings,
      transitionDuration: const Duration(milliseconds: 260),
      reverseTransitionDuration: const Duration(milliseconds: 220),
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.02, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    );
  }
}

class _MissingArgumentScreen extends StatelessWidget {
  const _MissingArgumentScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Pelanggaran')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.description_outlined, size: 48),
              const SizedBox(height: 12),
              const Text('Data pelanggaran tidak tersedia.'),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _UnknownRouteScreen extends StatelessWidget {
  const _UnknownRouteScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Halaman tidak ditemukan')),
      body: Center(
        child: FilledButton(
          onPressed: () =>
              Navigator.of(context)
                  .pushNamedAndRemoveUntil(AppRoutes.login, (route) => false),
          child: const Text('Kembali ke Login'),
        ),
      ),
    );
  }
}
