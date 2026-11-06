import '../models/statistics_model.dart';

abstract class StatisticsService {
  Future<DashboardData> fetchDashboard();

  Future<StatisticsData> fetchStatistics();
}
