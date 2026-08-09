class FamilyMemberModel {
  final String id;
  final String residentId;
  final String name;
  final String relation;
  final String ageGroup;
  final String? createdAt;

  FamilyMemberModel({
    required this.id,
    required this.residentId,
    required this.name,
    required this.relation,
    required this.ageGroup,
    this.createdAt,
  });

  factory FamilyMemberModel.fromJson(Map<String, dynamic> json) {
    return FamilyMemberModel(
      id: json['id'] as String,
      residentId: json['resident_id'] as String,
      name: json['name'] as String,
      relation: json['relation'] as String,
      ageGroup: json['age_group'] as String,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'resident_id': residentId,
      'name': name,
      'relation': relation,
      'age_group': ageGroup,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}
