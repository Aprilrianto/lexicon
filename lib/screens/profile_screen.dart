// Halaman Profile (hanya untuk menampilkan profil & navigasi ke Edit)
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
  Map<String, dynamic>? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user!.id)
        .single();
    setState(() {
      _profile = data;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Profil")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(24),
              children: [
                Center(
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _profile!["avatar_url"] != null && _profile!["avatar_url"].toString().isNotEmpty
                        ? NetworkImage(_profile!["avatar_url"]) as ImageProvider
                        : null,
                    child: (_profile!["avatar_url"] == null || _profile!["avatar_url"].isEmpty)
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
                const SizedBox(height: 12),
                Center(child: Text(_profile!["full_name"] ?? '-', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                Center(child: Text('@${_profile!["username"] ?? ''}', style: const TextStyle(color: Colors.grey))),
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
                  _profile!["bio"] ?? 'Belum ada bio.',
                  style: const TextStyle(color: Colors.black87),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const EditProfileScreen()),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profil"),
                )
              ],
            ),
    );
  }
}