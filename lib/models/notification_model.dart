enum NotificationCategory { violation, camera, system }

extension NotificationCategoryLabel on NotificationCategory {
  String get label => switch (this) {
    NotificationCategory.violation => 'Pelanggaran',
    NotificationCategory.camera => 'Kamera',
    NotificationCategory.system => 'Sistem',
  };
}

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.category,
    required this.createdAt,
    this.isRead = false,
    this.violationId,
  });

  final String id;
  final String title;
  final String message;
  final NotificationCategory category;
  final DateTime createdAt;
  final bool isRead;
  final String? violationId;

  NotificationModel copyWith({bool? isRead}) {
    return NotificationModel(
      id: id,
      title: title,
      message: message,
      category: category,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      violationId: violationId,
    );
  }
}
