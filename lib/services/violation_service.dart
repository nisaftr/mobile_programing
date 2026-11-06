import '../models/violation_model.dart';

class ViolationsPage {
  const ViolationsPage({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  final List<ViolationModel> items;
  final int total;
  final int page;
  final int limit;

  bool get hasMore => page * limit < total;
}

abstract class ViolationService {
  Future<ViolationsPage> fetchViolations({
    String query = '',
    VehicleType? vehicleType,
    ViolationStatus? status,
    DateTime? date,
    int page = 1,
    int limit = 6,
  });

  Future<ViolationModel> fetchById(String id);

  Future<ViolationModel> verify({
    required String id,
    required ViolationStatus status,
    String? note,
  });
}
