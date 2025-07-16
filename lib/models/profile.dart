// models/profile.dart

class Profile {
  final String id;
  final String fullName;
  final String username;
  final String avatarUrl;
  final String bio;
  final String role; // <-- BARU: Tambahkan field role

  Profile({
    required this.id,
    required this.fullName,
    required this.username,
    required this.avatarUrl,
    required this.bio,
    required this.role, // <-- BARU: Tambahkan di constructor
  });

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] ?? '',
      fullName: map['full_name'] ?? '',
      username: map['username'] ?? '',
      avatarUrl: map['avatar_url'] ?? '',
      bio: map['bio'] ?? '',
      // <-- BARU: Ambil data 'role', default ke 'user' jika tidak ada
      role: map['role'] ?? 'user',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'username': username,
      'avatar_url': avatarUrl,
      'bio': bio,
      'role': role, // <-- BARU: Tambahkan ke map
    };
  }
}
