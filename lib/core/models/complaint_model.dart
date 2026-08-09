class ComplaintModel {
  final String id;
  final String? residentId;
  final String? apartmentId;
  final String title;
  final String category;
  final String? description;
  final List<String> images;
  final String? location;
  final bool isEmergency;
  final String status;
  final String? assignedStaffId;
  final String? createdAt;
  final String? updatedAt;
  final String? expectedResponseAt;
  final String? resolutionNotes;
  final String ticketId;

  ComplaintModel({
    required this.id,
    this.residentId,
    this.apartmentId,
    required this.title,
    required this.category,
    this.description,
    this.images = const [],
    this.location,
    this.isEmergency = false,
    required this.status,
    this.assignedStaffId,
    this.createdAt,
    this.updatedAt,
    this.expectedResponseAt,
    this.resolutionNotes,
    required this.ticketId,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      residentId: json['resident_id'] as String?,
      apartmentId: json['apartment_id'] as String?,
      title: json['title'] as String? ?? '',
      category: json['category'] as String? ?? 'Other',
      description: json['description'] as String?,
      images: (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ?? [],
      location: json['location_label'] as String?,
      isEmergency: (json['priority'] as String?)?.toLowerCase() == 'high',
      status: json['status'] as String? ?? 'Open',
      assignedStaffId: json['assigned_staff_id'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      expectedResponseAt: json['expected_response_at'] as String?,
      resolutionNotes: json['resolution_notes'] as String?,
      ticketId: (json['id'] as String).substring(0, 8).toUpperCase(), // pseudo ticket id
    );
  }
}
