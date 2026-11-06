import '../../core/config/app_config.dart';
import '../../models/violation_model.dart';
import '../service_exception.dart';
import '../violation_service.dart';
import 'mock_data.dart';

class MockViolationService implements ViolationService {
  MockViolationService()
    : _items = MockData.createViolations()
        ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));

  final List<ViolationModel> _items;

  List<ViolationModel> get all => List.unmodifiable(_items);

  @override
  Future<ViolationsPage> fetchViolations({
    String query = '',
    VehicleType? vehicleType,
    ViolationStatus? status,
    DateTime? date,
    int page = 1,
    int limit = 6,
  }) async {
    await Future<void>.delayed(AppConfig.mockDelay);
    final normalized = query.trim().toLowerCase();
    final filtered = _items.where((item) {
      final matchesQuery =
          normalized.isEmpty ||
          item.id.toLowerCase().contains(normalized) ||
          (item.plateNumber ?? '').toLowerCase().contains(normalized) ||
          item.location.toLowerCase().contains(normalized) ||
          item.cameraName.toLowerCase().contains(normalized);
      final matchesType =
          vehicleType == null || item.vehicleType == vehicleType;
      final matchesStatus = status == null || item.status == status;
      final matchesDate =
          date == null ||
          (item.occurredAt.year == date.year &&
              item.occurredAt.month == date.month &&
              item.occurredAt.day == date.day);
      return matchesQuery && matchesType && matchesStatus && matchesDate;
    }).toList();

    final start = (page - 1) * limit;
    if (start >= filtered.length) {
      return ViolationsPage(
        items: const [],
        total: filtered.length,
        page: page,
        limit: limit,
      );
    }
    final end = (start + limit).clamp(0, filtered.length);
    return ViolationsPage(
      items: filtered.sublist(start, end),
      total: filtered.length,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<ViolationModel> fetchById(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final item = _items.where((element) => element.id == id).firstOrNull;
    if (item == null) {
      throw const ServiceException('Data pelanggaran tidak ditemukan.');
    }
    return item;
  }

  @override
  Future<ViolationModel> verify({
    required String id,
    required ViolationStatus status,
    String? note,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));
    final index = _items.indexWhere((element) => element.id == id);
    if (index == -1) {
      throw const ServiceException('Data pelanggaran tidak ditemukan.');
    }
    final updated = _items[index].copyWith(status: status, officerNote: note);
    _items[index] = updated;
    return updated;
  }
}
