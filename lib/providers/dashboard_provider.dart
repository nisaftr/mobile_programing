import 'package:flutter/foundation.dart';

import '../models/statistics_model.dart';
import '../services/service_exception.dart';
import '../services/statistics_service.dart';

class DashboardProvider extends ChangeNotifier {
  DashboardProvider(this._service);

  final StatisticsService _service;

  DashboardData? _data;
  bool _isLoading = false;
  String? _error;

  DashboardData? get data => _data;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> load({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    if (!refresh) _error = null;
    notifyListeners();
    try {
      _data = await _service.fetchDashboard();
      _error = null;
    } on ServiceException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Gagal memuat ringkasan dashboard.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
