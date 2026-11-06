import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../providers/notification_provider.dart';
import '../widgets/bottom_navbar.dart';
import 'dashboard/dashboard_screen.dart';
import 'monitoring/live_monitoring_screen.dart';
import 'profile/profile_screen.dart';
import 'statistics/statistics_screen.dart';
import 'violations/violation_list_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final notifications = context.read<NotificationProvider>();
      if (notifications.items.isEmpty) notifications.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppProvider>();
    final unread = context.watch<NotificationProvider>().unreadCount;
    final screens = <Widget>[
      const DashboardScreen(),
      LiveMonitoringScreen(active: app.tabIndex == 1),
      const ViolationListScreen(),
      const StatisticsScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      body: IndexedStack(
        index: app.tabIndex,
        children: [
          for (var i = 0; i < screens.length; i++)
            TickerMode(enabled: app.tabIndex == i, child: screens[i]),
        ],
      ),
      bottomNavigationBar: BottomNavbar(
        selectedIndex: app.tabIndex,
        unreadNotifications: unread,
        onTap: app.setTab,
      ),
    );
  }
}
