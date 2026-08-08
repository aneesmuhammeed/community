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
    return UserModel(
      residentId: json['resident_id'] ?? '55555555-5555-5555-5555-555555555555',
      societyId: json['society_id'] ?? '11111111-1111-1111-1111-111111111111',
      apartmentId: json['apartment_id'] ?? '33333333-3333-3333-3333-333333333333',
      name: json['full_name'] as String? ?? 'Arjun Mehta',
      societyName: json['society_name'] as String? ?? 'Maple Heights Residency',
      block: json['block_name'] as String? ?? 'Block C',
      apartment: json['unit_number'] as String? ?? 'Apt 403',
      phone: json['phone'] as String? ?? '+91 98765 43210',
      email: json['email'] as String? ?? 'arjun.mehta@gmail.com',
      role: json['role'] as String? ?? 'Resident',
      residentType: json['resident_type'] as String? ?? 'Owner',
      gender: json['gender'] as String? ?? 'male',
      ageGroup: json['age_group'] as String? ?? '25-35',
      heritage: json['heritage'] as String? ?? 'South Asian',
      avatarIndex: json['avatar_index'] as int? ?? 0,
    );
  }
}

// Keeping a mutable or observable state might be better, but we will use a global variable or provider for now.
UserModel currentUser = testUser;

const testUser = UserModel(
  residentId: '55555555-5555-5555-5555-555555555555',
  societyId: '11111111-1111-1111-1111-111111111111',
  apartmentId: '33333333-3333-3333-3333-333333333333',
  name: 'Arjun Mehta',
  societyName: 'Maple Heights Residency',
  block: 'Block C',
  apartment: 'Apt 403',
  phone: '+91 98765 43210',
  email: 'arjun.mehta@gmail.com',
  role: 'Resident',
  residentType: 'Owner',
  gender: 'male',
  ageGroup: '25-35',
  heritage: 'South Asian',
  avatarIndex: 0,
);
