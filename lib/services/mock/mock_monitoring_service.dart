import '../../models/camera_status_model.dart';
import '../../models/detection_model.dart';
import '../../models/violation_model.dart';
import '../monitoring_service.dart';
import 'mock_data.dart';

class MockMonitoringService implements MonitoringService {
  int _tick = 0;

  @override
  Future<List<CameraStatusModel>> fetchCameras() async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    return MockData.createCameras();
  }

  @override
  Future<MonitoringSnapshot> fetchSnapshot(String cameraId) async {
    await Future<void>.delayed(const Duration(milliseconds: 180));
    _tick++;
    final now = DateTime.now();
    final cameras = MockData.createCameras();
    final camera = cameras.firstWhere(
      (item) => item.id == cameraId,
      orElse: () => cameras.first,
    );
    final shift = (_tick % 4) * 0.04;
    final detections = <DetectionModel>[
      DetectionModel(
        id: 'DET-$_tick-01',
        vehicleType: VehicleType.motorcycle,
        confidence: 0.91,
        boundingBox: BoundingBox(
          x: 0.16 + shift,
          y: 0.46,
          width: 0.13,
          height: 0.24,
        ),
        isInBusway: false,
        detectedAt: now,
      ),
      DetectionModel(
        id: 'DET-$_tick-02',
        vehicleType: VehicleType.car,
        confidence: 0.88,
        boundingBox: BoundingBox(
          x: 0.46 + shift,
          y: 0.38,
          width: 0.24,
          height: 0.25,
        ),
        isInBusway: true,
        detectedAt: now,
      ),
      DetectionModel(
        id: 'DET-$_tick-03',
        vehicleType: VehicleType.motorcycle,
        confidence: 0.79,
        boundingBox: BoundingBox(
          x: (_tick % 3) * 0.05 + 0.68,
          y: 0.52,
          width: 0.12,
          height: 0.22,
        ),
        isInBusway: true,
        detectedAt: now,
      ),
      DetectionModel(
        id: 'DET-$_tick-04',
        vehicleType: VehicleType.car,
        confidence: 0.84,
        boundingBox: BoundingBox(
          x: 0.30,
          y: _tick.isEven ? 0.34 : 0.40,
          width: 0.22,
          height: 0.23,
        ),
        isInBusway: false,
        detectedAt: now,
      ),
    ];

    final violation = detections.any((item) => item.isInBusway);
    return MonitoringSnapshot(
      cameraId: camera.id,
      cameraName: camera.name,
      isOnline: camera.isOnline,
      detections: detections,
      fps: 24 + (_tick % 3),
      hasViolationAlert: violation,
      violationMessage: violation
          ? 'Indikasi kendaraan memasuki jalur busway terdeteksi.'
          : null,
      updatedAt: now,
    );
  }
}
