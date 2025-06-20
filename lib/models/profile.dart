class Profile {
  final String id;
  final String fullName;
  final String username;
  final String avatarUrl;
  final String bio;

  Profile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.avatarUrl,
    required this.bio,
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      fullName: map['full_name'] ?? '',
      username: map['username'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      bio: map['bio'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
    };
  }
}
