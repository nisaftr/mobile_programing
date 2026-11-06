import 'package:flutter/foundation.dart';

import '../models/violation_model.dart';
import '../services/service_exception.dart';
import '../services/violation_service.dart';

class ViolationProvider extends ChangeNotifier {
  ViolationProvider(this._service);

  final ViolationService _service;
  static const _pageSize = 6;

  final List<ViolationModel> _items = [];
  String _query = '';
  VehicleType? _vehicleType;
  ViolationStatus? _status;
  DateTime? _date;
  int _page = 1;
  int _total = 0;
  bool _isLoading = false;
  bool _isLoadingMore = false;
  bool _hasMore = false;
  String? _error;

  List<ViolationModel> get items => List.unmodifiable(_items);
  String get query => _query;
  VehicleType? get vehicleType => _vehicleType;
  ViolationStatus? get status => _status;
  DateTime? get date => _date;
  int get total => _total;
  bool get isLoading => _isLoading;
  bool get isLoadingMore => _isLoadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;
  bool get hasActiveFilter =>
      _query.isNotEmpty ||
      _vehicleType != null ||
      _status != null ||
      _date != null;

  Future<void> load({bool showLoading = true}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }
    try {
      final result = await _service.fetchViolations(
        query: _query,
        vehicleType: _vehicleType,
        status: _status,
        date: _date,
        page: 1,
        limit: _pageSize,
      );
      _items
        ..clear()
        ..addAll(result.items);
      _page = 1;
      _total = result.total;
      _hasMore = result.hasMore;
      _error = null;
    } on ServiceException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Gagal memuat data pelanggaran.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadMore() async {
    if (_isLoadingMore || !_hasMore) return;
    _isLoadingMore = true;
    notifyListeners();
    try {
      final result = await _service.fetchViolations(
        query: _query,
        vehicleType: _vehicleType,
        status: _status,
        date: _date,
        page: _page + 1,
        limit: _pageSize,
      );
      _page = result.page;
      _total = result.total;
      _items.addAll(result.items);
      _hasMore = result.hasMore;
      _error = null;
    } on ServiceException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Gagal memuat data berikutnya.';
    } finally {
      _isLoadingMore = false;
      notifyListeners();
    }
  }

  void search(String value) {
    if (_query == value) return;
    _query = value;
    load();
  }

  void setVehicleType(VehicleType? value) {
    _vehicleType = value;
    load();
  }

  void setStatus(ViolationStatus? value) {
    _status = value;
    load();
  }

  void setDate(DateTime? value) {
    _date = value;
    load();
  }

  void clearFilters() {
    _query = '';
    _vehicleType = null;
    _status = null;
    _date = null;
    load();
  }

  Future<void> refresh() => load(showLoading: false);

  Future<void> updateStatus(
    String id,
    ViolationStatus status, {
    String? note,
  }) async {
    final updated = await _service.verify(id: id, status: status, note: note);
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = updated;
      notifyListeners();
    }
  }
}
