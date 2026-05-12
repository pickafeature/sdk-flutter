class FeatureRequest {
  final String id;
  final String title;
  final String description;
  final String content;
  final int upvotes;
  final String status;
  final String? category;
  final String? priority;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const FeatureRequest({
    required this.id,
    required this.title,
    required this.description,
    required this.content,
    required this.upvotes,
    required this.status,
    this.category,
    this.priority,
    required this.createdAt,
    this.updatedAt,
  });

  factory FeatureRequest.fromJson(Map<String, dynamic> json) {
    final createdAtRaw = json['createdAt'];
    DateTime createdAt;

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

    final updatedAtRaw = json['updatedAt'];
    DateTime? updatedAt;

    if (updatedAtRaw != null) {
      if (updatedAtRaw is Map && updatedAtRaw.containsKey('_seconds')) {
        updatedAt = DateTime.fromMillisecondsSinceEpoch(
          (updatedAtRaw['_seconds'] as int) * 1000 +
              ((updatedAtRaw['_nanoseconds'] as int) ~/ 1000000),
        );
      } else if (updatedAtRaw is String) {
        updatedAt = DateTime.tryParse(updatedAtRaw);
      }
    }

    return FeatureRequest(
      id: json['id'] ?? '',
      title: json['title'] ?? json['content'] ?? '',
      description: json['description'] ?? json['content'] ?? '',
      content: json['content'] ?? '',
      upvotes: json['upvotes'] ?? 0,
      status: json['status'] ?? 'pending',
      category: json['category'],
      priority: json['priority'],
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'content': content,
      'upvotes': upvotes,
      'status': status,
      if (category != null) 'category': category,
      if (priority != null) 'priority': priority,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  FeatureRequest copyWith({
    String? id,
    String? title,
    String? description,
    String? content,
    int? upvotes,
    String? status,
    String? category,
    String? priority,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FeatureRequest(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      content: content ?? this.content,
      upvotes: upvotes ?? this.upvotes,
      status: status ?? this.status,
      category: category ?? this.category,
      priority: priority ?? this.priority,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FeatureRequest &&
        other.id == id &&
        other.title == title &&
        other.description == description &&
        other.content == content &&
        other.upvotes == upvotes &&
        other.status == status &&
        other.category == category &&
        other.priority == priority &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      title,
      description,
      content,
      upvotes,
      status,
      category,
      priority,
      createdAt,
      updatedAt,
    );
  }

  @override
  String toString() {
    return 'FeatureRequest(id: $id, title: $title, upvotes: $upvotes, status: $status)';
  }
}
