import 'package:flutter/foundation.dart';

import '../models/notification_model.dart';
import '../services/notification_service.dart';
import '../services/service_exception.dart';

class NotificationProvider extends ChangeNotifier {
  NotificationProvider(this._service);

  final NotificationService _service;

  List<NotificationModel> _items = [];
  bool _isLoading = false;
  String? _error;

  List<NotificationModel> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get unreadCount => _items.where((item) => !item.isRead).length;

  Future<void> load({bool refresh = false}) async {
    if (_isLoading) return;
    _isLoading = true;
    if (!refresh) _error = null;
    notifyListeners();
    try {
      _items = await _service.fetchNotifications();
      _error = null;
    } on ServiceException catch (error) {
      _error = error.message;
    } catch (_) {
      _error = 'Gagal memuat notifikasi.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> markRead(String id) async {
    await _service.markRead(id);
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  Future<void> markAllRead() async {
    await _service.markAllRead();
    _items = _items.map((item) => item.copyWith(isRead: true)).toList();
    notifyListeners();
  }
}
