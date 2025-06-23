import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'EditProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user!.id)
        .single();

    return data;
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Gagal memuat profil."));
          }

          final profile = snapshot.data!;
          final avatarUrl = profile["avatar_url"] ?? '';
          final fullName = profile["full_name"] ?? 'Tanpa Nama';
          final username = profile["username"] ?? '';
          final bio = profile["bio"] ?? 'Belum ada bio.';

          return RefreshIndicator(
            onRefresh: () async => _refreshProfile(),
            child: ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: avatarUrl.isNotEmpty
                        ? NetworkImage(avatarUrl)
                        : null,
                    child: avatarUrl.isEmpty
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    fullName,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                if (username.isNotEmpty)
                  Center(
                    child: Text(
                      '@$username',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                const SizedBox(height: 20),
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Column(children: [Text("1"), Text("Daftar Bacaan")]),
                    Column(children: [Text("2"), Text("Pengikut")]),
                  ],
                ),
                const Divider(height: 40),
                const Text("Tentang Kamu", style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  bio,
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                    if (result == true) {
                      _refreshProfile();
                    }
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profil"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
