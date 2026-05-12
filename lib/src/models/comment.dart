class Comment {
  final String id;
  final String content;
  final DateTime createdAt;

  Comment({required this.id, required this.content, required this.createdAt});

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
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
