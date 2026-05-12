/// Represents a user in the pick a feature system.
///
/// In v1.0 only [email] is sent to the backend (attached to future feedback
/// submissions). [customId] is auto-generated internally and used as the
/// stable per-user identifier across votes and submissions. [name] is stored
/// locally for app convenience but is not yet wired through the backend.
class PickAFeatureUser {
  final String? email;
  final String? name;
  final String? customId;
  final DateTime? lastUpdated;

  const PickAFeatureUser({
    this.email,
    this.name,
    this.customId,
    this.lastUpdated,
  });

  PickAFeatureUser copyWith({
    String? email,
    String? name,
    String? customId,
    DateTime? lastUpdated,
  }) {
    return PickAFeatureUser(
      email: email ?? this.email,
      name: name ?? this.name,
      customId: customId ?? this.customId,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'name': name,
      'customId': customId,
      'lastUpdated': lastUpdated?.toIso8601String(),
    };
  }

  factory PickAFeatureUser.fromJson(Map<String, dynamic> json) {
    return PickAFeatureUser(
      email: json['email'],
      name: json['name'],
      customId: json['customId'],
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'])
          : null,
    );
  }
}
