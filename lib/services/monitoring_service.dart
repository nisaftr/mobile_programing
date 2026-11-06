import '../models/camera_status_model.dart';
import '../models/detection_model.dart';

abstract class MonitoringService {
  Future<List<CameraStatusModel>> fetchCameras();

  Future<MonitoringSnapshot> fetchSnapshot(String cameraId);
}
