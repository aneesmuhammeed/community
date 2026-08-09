class AnnouncementModel {
  final String id;
  final String title;
  final String body;
  final String tag;
  final String icon;
  final bool isPinned;
  final String publishAt;

  AnnouncementModel({
    required this.id,
    required this.title,
    required this.body,
    required this.tag,
    required this.icon,
    required this.isPinned,
    required this.publishAt,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    return AnnouncementModel(
      id: json['id'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      tag: json['tag'] as String,
      icon: json['icon'] as String? ?? 'info',
      isPinned: json['is_pinned'] as bool? ?? false,
      publishAt: (json['publish_at'] ?? json['created_at']) as String,
    );
  }
}
