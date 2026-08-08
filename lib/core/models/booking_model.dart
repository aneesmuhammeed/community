class BookingModel {
  final String id;
  final String facility;
  final String date;
  final String time;
  final String status;
  final String icon;

  BookingModel({
    required this.id,
    required this.facility,
    required this.date,
    required this.time,
    required this.status,
    required this.icon,
  });

  factory BookingModel.fromJson(Map<String, dynamic> json) {
    final facilityData = json['facilities'] as Map<String, dynamic>? ?? {};
    
    return BookingModel(
      id: json['id'] as String,
      facility: facilityData['name'] as String? ?? 'Facility',
      date: json['booking_date'] as String,
      time: '${json['start_time']} - ${json['end_time']}',
      status: json['status'] as String,
      icon: facilityData['icon'] as String? ?? 'building',
    );
  }
}
