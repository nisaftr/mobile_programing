import 'camera_status_model.dart';
import 'violation_model.dart';

class ChartPoint {
  const ChartPoint({required this.label, required this.value});

  final String label;
  final double value;
}

class DashboardData {
  const DashboardData({
    required this.totalViolations,
    required this.todayViolations,
    required this.motorcycleCount,
    required this.carCount,
    required this.verifiedCount,
    required this.pendingCount,
    required this.weeklyTrend,
    required this.recentViolations,
    required this.cameras,
    required this.serverOnline,
  });

  final int totalViolations;
  final int todayViolations;
  final int motorcycleCount;
  final int carCount;
  final int verifiedCount;
  final int pendingCount;
  final List<ChartPoint> weeklyTrend;
  final List<ViolationModel> recentViolations;
  final List<CameraStatusModel> cameras;
  final bool serverOnline;
}

class StatisticsData {
  const StatisticsData({
    required this.daily,
    required this.weekly,
    required this.monthly,
    required this.totalDetected,
    required this.totalViolations,
    required this.verified,
    required this.pending,
    required this.motorcycle,
    required this.car,
  });

  final List<ChartPoint> daily;
  final List<ChartPoint> weekly;
  final List<ChartPoint> monthly;
  final int totalDetected;
  final int totalViolations;
  final int verified;
  final int pending;
  final int motorcycle;
  final int car;
}
