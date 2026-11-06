import '../models/notification_model.dart';

abstract class NotificationService {
  Future<List<NotificationModel>> fetchNotifications();

  Future<void> markRead(String id);

  Future<void> markAllRead();
}
