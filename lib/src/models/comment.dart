class Comment {
  final String id;
  final String content;
  final DateTime createdAt;

  /// `user` for app users, `admin` for replies the project owner posted from
  /// the dashboard. The UI shows a Team badge on the latter.
  final String authorType;

  Comment({
    required this.id,
    required this.content,
    required this.createdAt,
    this.authorType = 'user',
  });

  bool get isTeam => authorType == 'admin';

  factory Comment.fromJson(Map<String, dynamic> json) {
    DateTime createdAt;
    final createdAtRaw = json['createdAt'];
    if (createdAtRaw is Map && createdAtRaw.containsKey('_seconds')) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(
        (createdAtRaw['_seconds'] as int) * 1000 +
            ((createdAtRaw['_nanoseconds'] as int) ~/ 1000000),
      );
    } else if (createdAtRaw is String) {
      createdAt = DateTime.tryParse(createdAtRaw) ?? DateTime.now();
    } else {
      createdAt = DateTime.now();
    }
    return Comment(
      id: json['id'] ?? '',
      content: json['text'] ?? '',
      createdAt: createdAt,
      authorType: json['authorType'] ?? 'user',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
      'authorType': authorType,
    };
  }
}
