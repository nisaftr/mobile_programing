import '../../models/camera_status_model.dart';
import '../../models/notification_model.dart';
import '../../models/statistics_model.dart';
import '../../models/user_model.dart';
import '../../models/violation_model.dart';

abstract final class MockData {
  static const user = UserModel(
    id: 'USR-001',
    name: 'Petugas ETLE',
    email: 'petugas@etle.id',
    role: 'Petugas Verifikasi',
    token: 'mock-session-token',
  );

  static const _locations = [
    'Jl. Sudirman - Busway Koridor 1',
    'Jl. Thamrin - Busway Koridor 1',
    'Jl. Gatot Subroto - Koridor 9',
    'Jl. Rasuna Said - Koridor 6',
    'Jl. Kuningan - Koridor 6',
  ];

  static const _cameras = [
    'CAM-SUDIRMAN-01',
    'CAM-THAMRIN-02',
    'CAM-GATSU-03',
    'CAM-RASUNA-04',
    'CAM-KUNINGAN-05',
  ];

  static const _plates = [
    'B 1234 XYZ',
    'D 8821 KQ',
    'F 7712 TR',
    'B 9090 PD',
    'AB 5566 ZA',
    'B 2244 SR',
  ];

  static List<ViolationModel> createViolations() {
    final now = DateTime.now();
    return List.generate(18, (index) {
      final minutesAgo = switch (index) {
        0 => 12,
        1 => 46,
        2 => 95,
        3 => 180,
        4 => 320,
        5 => 500,
        6 => 780,
        7 => 1100,
        8 => 1500,
        9 => 1900,
        10 => 2400,
        _ => 2400 + (index - 10) * 720,
      };
      final isToday = minutesAgo < now.hour * 60 + now.minute;
      final occurredAt = isToday
          ? now.subtract(Duration(minutes: minutesAgo))
          : DateTime(
              now.year,
              now.month,
              now.day,
              now.hour,
              now.minute,
            ).subtract(Duration(minutes: minutesAgo));
      final type = switch (index % 5) {
        0 || 2 || 3 => VehicleType.motorcycle,
        1 || 4 => VehicleType.car,
        _ => VehicleType.unknown,
      };
      final status = switch (index % 6) {
        0 || 1 || 4 => ViolationStatus.pending,
        2 || 3 => ViolationStatus.verified,
        _ => ViolationStatus.invalid,
      };
      return ViolationModel(
        id: 'ETLE-2026-${(index + 1).toString().padLeft(4, '0')}',
        vehicleType: type,
        plateNumber: type == VehicleType.unknown ? null : _plates[index % 6],
        occurredAt: occurredAt,
        location: _locations[index % _locations.length],
        cameraName: _cameras[index % _cameras.length],
        status: status,
        confidence: 0.72 + (index % 7) * 0.04,
        boundingBox: BoundingBox(
          x: 0.18 + (index % 4) * 0.12,
          y: 0.32 + (index % 3) * 0.08,
          width: type == VehicleType.car ? 0.26 : 0.16,
          height: type == VehicleType.car ? 0.24 : 0.3,
        ),
        officerNote: index % 6 == 3
            ? 'Kendaraan terlihat jelas berada di jalur busway.'
            : null,
      );
    });
  }

  static List<CameraStatusModel> createCameras() {
    final now = DateTime.now();
    return [
      CameraStatusModel(
        id: 'CAM-01',
        name: 'Kamera Sudirman',
        location: 'Jl. Sudirman',
        isOnline: true,
        lastSeen: now,
      ),
      CameraStatusModel(
        id: 'CAM-02',
        name: 'Kamera Thamrin',
        location: 'Jl. Thamrin',
        isOnline: true,
        lastSeen: now.subtract(const Duration(seconds: 4)),
      ),
      CameraStatusModel(
        id: 'CAM-03',
        name: 'Kamera Gatot Subroto',
        location: 'Jl. Gatot Subroto',
        isOnline: false,
        lastSeen: now.subtract(const Duration(minutes: 18)),
      ),
      CameraStatusModel(
        id: 'CAM-04',
        name: 'Kamera Rasuna Said',
        location: 'Jl. Rasuna Said',
        isOnline: true,
        lastSeen: now.subtract(const Duration(seconds: 2)),
      ),
    ];
  }

  static List<NotificationModel> createNotifications() {
    final now = DateTime.now();
    return [
      NotificationModel(
        id: 'NTF-001',
        title: 'Indikasi pelanggaran baru',
        message: 'Motor B 1234 XYZ terdeteksi memasuki jalur busway di Jl. Sudirman.',
        category: NotificationCategory.violation,
        createdAt: now.subtract(const Duration(minutes: 12)),
        violationId: 'ETLE-2026-0001',
      ),
      NotificationModel(
        id: 'NTF-002',
        title: 'Data menunggu verifikasi',
        message: 'Terdapat 6 data indikasi pelanggaran menunggu pemeriksaan.',
        category: NotificationCategory.system,
        createdAt: now.subtract(const Duration(minutes: 40)),
      ),
      NotificationModel(
        id: 'NTF-003',
        title: 'Kamera Gatot Subroto offline',
        message: 'Kamera CAM-03 tidak mengirim data sejak 18 menit yang lalu.',
        category: NotificationCategory.camera,
        createdAt: now.subtract(const Duration(minutes: 58)),
      ),
      NotificationModel(
        id: 'NTF-004',
        title: 'Indikasi pelanggaran baru',
        message: 'Mobil D 8821 KQ terdeteksi berada di jalur busway.',
        category: NotificationCategory.violation,
        createdAt: now.subtract(const Duration(hours: 3)),
        isRead: true,
        violationId: 'ETLE-2026-0002',
      ),
      NotificationModel(
        id: 'NTF-005',
        title: 'Sinkronisasi selesai',
        message: 'Data deteksi kamera berhasil disinkronkan ke server.',
        category: NotificationCategory.system,
        createdAt: now.subtract(const Duration(days: 1)),
        isRead: true,
      ),
    ];
  }

  static List<ChartPoint> dailyTrend() {
    final now = DateTime.now();
    const values = [4.0, 7.0, 5.0, 9.0, 6.0, 8.0, 11.0];
    return List.generate(7, (index) {
      final date = now.subtract(Duration(days: 6 - index));
      return ChartPoint(label: _weekday(date.weekday), value: values[index]);
    });
  }

  static List<ChartPoint> weeklyTrend() {
    return const [
      ChartPoint(label: 'Minggu 1', value: 26),
      ChartPoint(label: 'Minggu 2', value: 34),
      ChartPoint(label: 'Minggu 3', value: 29),
      ChartPoint(label: 'Minggu 4', value: 41),
    ];
  }

  static List<ChartPoint> monthlyTrend() {
    final now = DateTime.now();
    const values = [78.0, 92.0, 64.0, 110.0, 96.0, 124.0];
    return List.generate(6, (index) {
      final date = DateTime(now.year, now.month - 5 + index);
      return ChartPoint(label: _shortMonth(date.month), value: values[index]);
    });
  }

  static String _weekday(int weekday) =>
      const ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'][weekday - 1];

  static String _shortMonth(int month) => const [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ][month - 1];
}
