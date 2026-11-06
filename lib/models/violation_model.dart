enum VehicleType { motorcycle, car, unknown }

extension VehicleTypeLabel on VehicleType {
  String get label => switch (this) {
    VehicleType.motorcycle => 'Motor',
    VehicleType.car => 'Mobil',
    VehicleType.unknown => 'Tidak diketahui',
  };

  String get apiValue => switch (this) {
    VehicleType.motorcycle => 'motorcycle',
    VehicleType.car => 'car',
    VehicleType.unknown => 'unknown',
  };
}

enum ViolationStatus { pending, verified, invalid }

extension ViolationStatusLabel on ViolationStatus {
  String get label => switch (this) {
    ViolationStatus.pending => 'Menunggu Verifikasi',
    ViolationStatus.verified => 'Terverifikasi',
    ViolationStatus.invalid => 'Tidak Valid',
  };

  String get shortLabel => switch (this) {
    ViolationStatus.pending => 'Menunggu',
    ViolationStatus.verified => 'Terverifikasi',
    ViolationStatus.invalid => 'Tidak Valid',
  };

  String get apiValue => name;
}

class BoundingBox {
  const BoundingBox({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  double get right => x + width;
  double get bottom => y + height;
}

class ViolationModel {
  const ViolationModel({
    required this.id,
    required this.vehicleType,
    required this.occurredAt,
    required this.location,
    required this.cameraName,
    required this.status,
    required this.confidence,
    required this.boundingBox,
    this.plateNumber,
    this.originalImageUrl,
    this.detectionImageUrl,
    this.officerNote,
  });

  final String id;
  final VehicleType vehicleType;
  final String? plateNumber;
  final DateTime occurredAt;
  final String location;
  final String cameraName;
  final ViolationStatus status;
  final double confidence;
  final BoundingBox boundingBox;
  final String? originalImageUrl;
  final String? detectionImageUrl;
  final String? officerNote;

  ViolationModel copyWith({
    VehicleType? vehicleType,
    String? plateNumber,
    DateTime? occurredAt,
    String? location,
    String? cameraName,
    ViolationStatus? status,
    double? confidence,
    BoundingBox? boundingBox,
    String? originalImageUrl,
    String? detectionImageUrl,
    String? officerNote,
  }) {
    return ViolationModel(
      id: id,
      vehicleType: vehicleType ?? this.vehicleType,
      plateNumber: plateNumber ?? this.plateNumber,
      occurredAt: occurredAt ?? this.occurredAt,
      location: location ?? this.location,
      cameraName: cameraName ?? this.cameraName,
      status: status ?? this.status,
      confidence: confidence ?? this.confidence,
      boundingBox: boundingBox ?? this.boundingBox,
      originalImageUrl: originalImageUrl ?? this.originalImageUrl,
      detectionImageUrl: detectionImageUrl ?? this.detectionImageUrl,
      officerNote: officerNote ?? this.officerNote,
    );
  }
}
