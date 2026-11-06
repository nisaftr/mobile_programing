import '../../models/notification_model.dart';
import '../notification_service.dart';
import 'mock_data.dart';

class MockNotificationService implements NotificationService {
  MockNotificationService()
    : _items = MockData.createNotifications()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  final List<NotificationModel> _items;

  @override
  Future<List<NotificationModel>> fetchNotifications() async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
    return List.unmodifiable(_items);
  }

  @override
  Future<void> markRead(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    final index = _items.indexWhere((item) => item.id == id);
    if (index != -1) {
      _items[index] = _items[index].copyWith(isRead: true);
    }
  }

  @override
  Future<void> markAllRead() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    for (var index = 0; index < _items.length; index++) {
      _items[index] = _items[index].copyWith(isRead: true);
    }
  }
}
