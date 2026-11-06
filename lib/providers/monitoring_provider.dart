import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/camera_status_model.dart';
import '../models/detection_model.dart';
import '../services/monitoring_service.dart';
import '../services/service_exception.dart';

class MonitoringProvider extends ChangeNotifier {
  MonitoringProvider(this._service);

  final MonitoringService _service;
  Timer? _timer;
  bool _disposed = false;

  List<CameraStatusModel> _cameras = [];
  MonitoringSnapshot? _snapshot;
  String? _selectedCameraId;
  bool _isLoading = false;
  String? _error;

  List<CameraStatusModel> get cameras => List.unmodifiable(_cameras);
  MonitoringSnapshot? get snapshot => _snapshot;
  String? get selectedCameraId => _selectedCameraId;
  bool get isLoading => _isLoading;
  String? get error => _error;

  CameraStatusModel? get selectedCamera {
    if (_selectedCameraId == null) return null;
    return _cameras.where((item) => item.id == _selectedCameraId).firstOrNull;
  }

  Future<void> start() async {
    if (_timer != null) return;
    await _loadCameras();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => refresh());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  Future<void> _loadCameras() async {
    _isLoading = true;
    _safeNotify();
    try {
      _cameras = await _service.fetchCameras();
      _selectedCameraId ??= _cameras.firstOrNull?.id;
      _error = null;
      await _fetchSnapshot();
    } on ServiceException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Gagal memuat status kamera.';
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> refresh() async {
    if (_selectedCameraId == null) return;
    await _fetchSnapshot();
  }

  Future<void> _fetchSnapshot() async {
    final cameraId = _selectedCameraId;
    if (cameraId == null) return;
    try {
      _snapshot = await _service.fetchSnapshot(cameraId);
      _error = null;
    } on ServiceException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Koneksi monitoring terputus.';
    }
    _safeNotify();
  }

  Future<void> selectCamera(String id) async {
    if (_selectedCameraId == id) return;
    _selectedCameraId = id;
    _snapshot = null;
    _safeNotify();
    await _fetchSnapshot();
  }

  void _safeNotify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    stop();
    super.dispose();
  }
}
