import 'package:flutter/foundation.dart';

import '../models/statistics_model.dart';
import '../services/service_exception.dart';
import '../services/statistics_service.dart';

enum StatisticsPeriod { daily, weekly, monthly }

extension StatisticsPeriodLabel on StatisticsPeriod {
  String get label => switch (this) {
    StatisticsPeriod.daily => 'Harian',
    StatisticsPeriod.weekly => 'Mingguan',
    StatisticsPeriod.monthly => 'Bulanan',
  };
}

class StatisticsProvider extends ChangeNotifier {
  StatisticsProvider(this._service);

  final StatisticsService _service;

  StatisticsData? _data;
  StatisticsPeriod _period = StatisticsPeriod.daily;
  bool _isLoading = false;
  String? _error;

  StatisticsData? get data => _data;
  StatisticsPeriod get period => _period;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<ChartPoint> get activeChart => switch (_period) {
    StatisticsPeriod.daily => _data?.daily ?? const [],
    StatisticsPeriod.weekly => _data?.weekly ?? const [],
    StatisticsPeriod.monthly => _data?.monthly ?? const [],
  };

  Future<void> load({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    if (!refresh) _error = null;
    notifyListeners();
    try {
      _data = await _service.fetchStatistics();
      _error = null;
    } on ServiceException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Gagal memuat statistik.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setPeriod(StatisticsPeriod period) {
    if (_period == period) return;
    _period = period;
    notifyListeners();
  }
}
