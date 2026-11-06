import '../../core/config/app_config.dart';
import '../../models/statistics_model.dart';
import '../../models/violation_model.dart';
import '../statistics_service.dart';
import 'mock_data.dart';
import 'mock_violation_service.dart';

class MockStatisticsService implements StatisticsService {
  MockStatisticsService(this._violationService);

  final MockViolationService _violationService;

  @override
  Future<DashboardData> fetchDashboard() async {
    await Future<void>.delayed(AppConfig.mockDelay);
    final items = _violationService.all;
    final now = DateTime.now();
    final today = items
        .where((item) => _isSameDay(item.occurredAt, now))
        .length;
    final motorcycles = items
        .where((item) => item.vehicleType == VehicleType.motorcycle)
        .length;
    final cars = items
        .where((item) => item.vehicleType == VehicleType.car)
        .length;
    final verified = items
        .where((item) => item.status == ViolationStatus.verified)
        .length;
    final pending = items
        .where((item) => item.status == ViolationStatus.pending)
        .length;

    return DashboardData(
      totalViolations: items.length,
      todayViolations: today,
      motorcycleCount: motorcycles,
      carCount: cars,
      verifiedCount: verified,
      pendingCount: pending,
      weeklyTrend: MockData.dailyTrend(),
      recentViolations: items.take(4).toList(),
      cameras: MockData.createCameras(),
      serverOnline: true,
    );
  }

  @override
  Future<StatisticsData> fetchStatistics() async {
    await Future<void>.delayed(AppConfig.mockDelay);
    final items = _violationService.all;
    final motorcycles = items
        .where((item) => item.vehicleType == VehicleType.motorcycle)
        .length;
    final cars = items
        .where((item) => item.vehicleType == VehicleType.car)
        .length;
    final verified = items
        .where((item) => item.status == ViolationStatus.verified)
        .length;
    final pending = items
        .where((item) => item.status == ViolationStatus.pending)
        .length;

    return StatisticsData(
      daily: MockData.dailyTrend(),
      weekly: MockData.weeklyTrend(),
      monthly: MockData.monthlyTrend(),
      totalDetected: items.length + 37,
      totalViolations: items.length,
      verified: verified,
      pending: pending,
      motorcycle: motorcycles,
      car: cars,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;
}
