class GuestInviteModel {
  final String id;
  final String name;
  final String relation;
  final String date;
  final String method;
  final String code;
  final String status;
  final String gender;
  final String heritage;
  final int avatarIndex;
  final String validUntil;
  final String otpValue;

  GuestInviteModel({
    required this.id,
    required this.name,
    required this.relation,
    required this.date,
    required this.method,
    required this.code,
    required this.status,
    required this.gender,
    required this.heritage,
    required this.avatarIndex,
    required this.validUntil,
    required this.otpValue,
  });

  factory GuestInviteModel.fromJson(Map<String, dynamic> json) {
    return GuestInviteModel(
      id: json['id'] as String,
      name: json['guest_name'] as String,
      relation: json['relation'] as String,
      date: json['valid_from'] as String,
      method: json['invite_method'] as String? ?? 'qr',
      code: json['invite_code'] as String? ?? '',
      status: (json['arrived_at'] != null && json['left_at'] == null) ? 'entered' : json['status'] as String,
      gender: 'male',
      heritage: 'South Asian',
      avatarIndex: 1,
      validUntil: json['valid_until'] as String? ?? '',
      otpValue: json['otp_value'] as String? ?? '',
    );
  }
}
