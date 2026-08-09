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
    
    // Convert 18:00:00 to 6:00 PM
    String formatTime(String? timeStr) {
      if (timeStr == null || timeStr.isEmpty) return '';
      final parts = timeStr.split(':');
      if (parts.length < 2) return timeStr;
      int hour = int.tryParse(parts[0]) ?? 0;
      int min = int.tryParse(parts[1]) ?? 0;
      final ampm = hour >= 12 ? 'PM' : 'AM';
      int h = hour % 12;
      if (h == 0) h = 12;
      return '$h:${min.toString().padLeft(2, '0')} $ampm';
    }

    final start = formatTime(json['start_time']?.toString());
    final end = formatTime(json['end_time']?.toString());

    return BookingModel(
      id: json['id']?.toString() ?? '',
      facility: facilityData['name'] as String? ?? 'Facility',
      date: json['booking_date']?.toString() ?? '',
      time: '$start - $end',
      status: json['status']?.toString() ?? 'pending',
      icon: facilityData['icon'] as String? ?? 'building',
    );
  }
}
