class UserModel {
  final String residentId;
  final String societyId;
  final String apartmentId;
  final String name;
  final String societyName;
  final String block;
  final String apartment;
  final String phone;
  final String email;
  final String role;
  final String residentType;
  final String gender;
  final String ageGroup;
  final String heritage;
  final int avatarIndex;

  const UserModel({
    required this.residentId,
    required this.societyId,
    required this.apartmentId,
    required this.name,
    required this.societyName,
    required this.block,
    required this.apartment,
    required this.phone,
    required this.email,
    required this.role,
    required this.residentType,
    required this.gender,
    required this.ageGroup,
    required this.heritage,
    required this.avatarIndex,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    if (json['resident_id'] == null || json['society_id'] == null || json['apartment_id'] == null) {
      throw Exception('Missing required IDs in user data');
    }
    return UserModel(
      residentId: json['resident_id'] as String,
      societyId: json['society_id'] as String,
      apartmentId: json['apartment_id'] as String,
      name: json['full_name'] as String? ?? 'Resident',
      societyName: json['society_name'] as String? ?? 'Society',
      block: json['block_name'] as String? ?? '',
      apartment: json['unit_number'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      role: json['role'] as String? ?? 'Resident',
      residentType: json['resident_type'] as String? ?? 'Owner',
      gender: json['gender'] as String? ?? 'male',
      ageGroup: json['age_group'] as String? ?? '',
      heritage: json['heritage'] as String? ?? '',
      avatarIndex: json['avatar_index'] as int? ?? 0,
    );
  }
  UserModel copyWith({
    String? residentId,
    String? societyId,
    String? apartmentId,
    String? name,
    String? societyName,
    String? block,
    String? apartment,
    String? phone,
    String? email,
    String? role,
    String? residentType,
    String? gender,
    String? ageGroup,
    String? heritage,
    int? avatarIndex,
  }) {
    return UserModel(
      residentId: residentId ?? this.residentId,
      societyId: societyId ?? this.societyId,
      apartmentId: apartmentId ?? this.apartmentId,
      name: name ?? this.name,
      societyName: societyName ?? this.societyName,
      block: block ?? this.block,
      apartment: apartment ?? this.apartment,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      role: role ?? this.role,
      residentType: residentType ?? this.residentType,
      gender: gender ?? this.gender,
      ageGroup: ageGroup ?? this.ageGroup,
      heritage: heritage ?? this.heritage,
      avatarIndex: avatarIndex ?? this.avatarIndex,
    );
  }
}
