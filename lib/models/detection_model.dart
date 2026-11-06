import 'violation_model.dart';

class DetectionModel {
  const DetectionModel({
    required this.id,
    required this.vehicleType,
    required this.confidence,
    required this.boundingBox,
    required this.isInBusway,
    required this.detectedAt,
  });

  final String id;
  final VehicleType vehicleType;
  final double confidence;
  final BoundingBox boundingBox;
  final bool isInBusway;
  final DateTime detectedAt;
}

class MonitoringSnapshot {
  const MonitoringSnapshot({
    required this.cameraId,
    required this.cameraName,
    required this.isOnline,
    required this.detections,
    required this.fps,
    required this.hasViolationAlert,
    required this.violationMessage,
    required this.updatedAt,
  });

  final String cameraId;
  final String cameraName;
  final bool isOnline;
  final List<DetectionModel> detections;
  final int fps;
  final bool hasViolationAlert;
  final String? violationMessage;
  final DateTime updatedAt;

  int get motorcycleCount => detections
      .where((item) => item.vehicleType == VehicleType.motorcycle)
      .length;

  int get carCount =>
      detections.where((item) => item.vehicleType == VehicleType.car).length;
}
