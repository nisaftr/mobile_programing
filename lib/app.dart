import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_strings.dart';
import 'core/routes/app_router.dart';
import 'core/routes/app_routes.dart';
import 'core/theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'providers/dashboard_provider.dart';
import 'providers/monitoring_provider.dart';
import 'providers/notification_provider.dart';
import 'providers/statistics_provider.dart';
import 'providers/violation_provider.dart';
import 'services/mock/mock_auth_service.dart';
import 'services/mock/mock_monitoring_service.dart';
import 'services/mock/mock_notification_service.dart';
import 'services/mock/mock_statistics_service.dart';
import 'services/mock/mock_violation_service.dart';

class EtleApp extends StatefulWidget {
  const EtleApp({super.key});

  @override
  State<EtleApp> createState() => _EtleAppState();
}

class _EtleAppState extends State<EtleApp> {
  late final _authService = MockAuthService();
  late final _violationService = MockViolationService();
  late final _statisticsService = MockStatisticsService(_violationService);
  late final _monitoringService = MockMonitoringService();
  late final _notificationService = MockNotificationService();

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppProvider(_authService)),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(_statisticsService),
        ),
        ChangeNotifierProvider(
          create: (_) => ViolationProvider(_violationService),
        ),
        ChangeNotifierProvider(
          create: (_) => MonitoringProvider(_monitoringService),
        ),
        ChangeNotifierProvider(
          create: (_) => StatisticsProvider(_statisticsService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(_notificationService),
        ),
      ],
      child: MaterialApp(
        title: AppStrings.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        initialRoute: AppRoutes.splash,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
  }
}
