class PollOptionModel {
  final String id;
  final String pollId;
  final String optionText;

  PollOptionModel({
    required this.id,
    required this.pollId,
    required this.optionText,
  });

  factory PollOptionModel.fromJson(Map<String, dynamic> json) {
    return PollOptionModel(
      id: json['id'] as String,
      pollId: json['poll_id'] as String,
      optionText: json['option_text'] as String,
    );
  }
}

class PollModel {
  final String id;
  final String societyId;
  final String title;
  final String? description;
  final String expiresAt;
  final String createdAt;
  final List<PollOptionModel> options;

  PollModel({
    required this.id,
    required this.societyId,
    required this.title,
    this.description,
    required this.expiresAt,
    required this.createdAt,
    required this.options,
  });

  factory PollModel.fromJson(Map<String, dynamic> json) {
    var optionsList = json['options'] as List? ?? [];
    List<PollOptionModel> parsedOptions = optionsList.map((i) => PollOptionModel.fromJson(i)).toList();

    return PollModel(
      id: json['id'] as String,
      societyId: json['society_id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      expiresAt: json['expires_at'] as String,
      createdAt: json['created_at'] as String,
      options: parsedOptions,
    );
  }
}
