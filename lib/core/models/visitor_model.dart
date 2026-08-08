class VisitorModel {
  final String id;
  final String name;
  final String time;
  final String purpose;
  final String status;
  final String gender;
  final String heritage;
  final int avatarIndex;

  VisitorModel({
    required this.id,
    required this.name,
    required this.time,
    required this.purpose,
    required this.status,
    required this.gender,
    required this.heritage,
    required this.avatarIndex,
  });

  factory VisitorModel.fromJson(Map<String, dynamic> json) {
    return VisitorModel(
      id: json['id'] as String,
      name: json['guest_name'] as String,
      time: json['valid_from'] as String,
      purpose: json['purpose'] as String? ?? 'Visit',
      status: json['status'] as String,
      gender: 'male', // Dummy fallback as native schema lacks this
      heritage: 'South Asian', // Dummy fallback
      avatarIndex: 1, // Dummy fallback
    );
  }
}
