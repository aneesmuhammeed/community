class ComplaintModel {
  final String id;
  final String title;
  final String category;
  final String date;
  final String status;
  final String ticketId;

  ComplaintModel({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.status,
    required this.ticketId,
  });

  factory ComplaintModel.fromJson(Map<String, dynamic> json) {
    return ComplaintModel(
      id: json['id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      date: json['created_at'] as String,
      status: json['status'] as String,
      ticketId: (json['id'] as String).substring(0, 8).toUpperCase(), // pseudo ticket id
    );
  }
}
