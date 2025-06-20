class Profile {
  final String id;
  final String fullName;
  final String avatarUrl;

  Profile({
    required this.id,
    required this.fullName,
    required this.avatarUrl,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      fullName: map['full_name'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }
}
