class VehicleModel {
  final String id;
  final String residentId;
  final String? make;
  final String? model;
  final String? color;
  final String registrationNo;
  final String vehicleType;
  final bool isActive;
  final String? createdAt;

  VehicleModel({
    required this.id,
    required this.residentId,
    this.make,
    this.model,
    this.color,
    required this.registrationNo,
    required this.vehicleType,
    required this.isActive,
    this.createdAt,
  });

  factory VehicleModel.fromJson(Map<String, dynamic> json) {
    return VehicleModel(
      id: json['id'] as String,
      residentId: json['resident_id'] as String,
      make: json['make'] as String?,
      model: json['model'] as String?,
      color: json['color'] as String?,
      registrationNo: json['registration_no'] as String? ?? 'Unknown',
      vehicleType: json['vehicle_type'] as String? ?? 'car',
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resident_id': residentId,
      if (make != null) 'make': make,
      if (model != null) 'model': model,
      if (color != null) 'color': color,
      'registration_no': registrationNo,
      'vehicle_type': vehicleType,
      'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
    };
  }

  String get displayTitle {
    String title = '${make ?? ''} ${model ?? ''}'.trim();
    if (title.isEmpty) {
      title = '${color ?? ''} $vehicleType'.toUpperCase().trim();
    }
    return title.isEmpty ? 'Unknown Vehicle' : title;
  }
}
