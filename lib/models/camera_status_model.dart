class CameraStatusModel {
  const CameraStatusModel({
    required this.id,
    required this.name,
    required this.location,
    required this.isOnline,
    required this.lastSeen,
  });

  final String id;
  final String name;
  final String location;
  final bool isOnline;
  final DateTime lastSeen;

  CameraStatusModel copyWith({bool? isOnline, DateTime? lastSeen}) {
    return CameraStatusModel(
      id: id,
      name: name,
      location: location,
      isOnline: isOnline ?? this.isOnline,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}
