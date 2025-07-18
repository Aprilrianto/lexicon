import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_screen.dart'; // Pastikan nama file ini benar
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = _loadProfile();
  }

  Future<Map<String, dynamic>> _loadProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      throw Exception('User tidak terautentikasi');
    }
    // Memastikan semua kolom yang dibutuhkan terpilih
    final data =
        await Supabase.instance.client
            .from('profiles')
            .select('username, avatar_url, bio')
            .eq('id', user.id)
            .single();
    return data;
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = _loadProfile();
    });
  }

  void _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Profil',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        centerTitle: true,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Gagal memuat profil."),
                  TextButton(
                    onPressed: _refreshProfile,
                    child: const Text('Coba Lagi'),
                  ),
                ],
              ),
            );
          }

          final profile = snapshot.data!;
          final avatarUrl = profile["avatar_url"];
          final username = profile["username"] ?? 'User';
          final bio = profile["bio"]; // Mengambil data bio

          return RefreshIndicator(
            onRefresh: () async => _refreshProfile(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Mengirim data bio ke widget header
                _buildProfileHeader(context, avatarUrl, username, bio),
                const SizedBox(height: 20),
                _buildOptionSection([
                  _OptionItem(
                    icon: Icons.history,
                    title: 'Bacaan Terakhir',
                    onTap: () {},
                  ),
                  _OptionItem(
                    icon: Icons.menu_book,
                    title: 'Preferensi Bacaan',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 20),
                _buildOptionSection([
                  _OptionItem(
                    icon: Icons.settings_outlined,
                    title: 'Pengaturan',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SettingsScreen(),
                        ),
                      );
                    },
                  ),
                  _OptionItem(
                    icon: Icons.help_outline,
                    title: 'Bantuan & Umpan Balik',
                    onTap: () {},
                  ),
                ]),
                const SizedBox(height: 20),
                _buildOptionSection([
                  _OptionItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    onTap: _logout,
                    color: Colors.red,
                  ),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // DIUBAH: Widget header profil sekarang menerima dan menampilkan bio
  Widget _buildProfileHeader(
    BuildContext context,
    String? avatarUrl,
    String username,
    String? bio,
  ) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditProfileScreen()),
          );
          _refreshProfile();
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          child: Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundImage:
                    (avatarUrl != null && avatarUrl.isNotEmpty)
                        ? NetworkImage(avatarUrl)
                        : null,
                child:
                    (avatarUrl == null || avatarUrl.isEmpty)
                        ? const Icon(Icons.person, size: 28)
                        : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    // Menampilkan bio jika ada dan tidak kosong
                    if (bio != null && bio.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        bio,
                        style: TextStyle(color: Colors.grey[600], fontSize: 14),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionSection(List<_OptionItem> items) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children:
            items.map((item) {
              return Column(
                children: [
                  ListTile(
                    leading: Icon(
                      item.icon,
                      color: item.color ?? Colors.black87,
                    ),
                    title: Text(
                      item.title,
                      style: TextStyle(color: item.color ?? Colors.black87),
                    ),
                    trailing:
                        item.onTap != _logout
                            ? const Icon(Icons.arrow_forward_ios, size: 16)
                            : null,
                    onTap: item.onTap,
                  ),
                  if (items.indexOf(item) < items.length - 1)
                    const Divider(height: 1, indent: 16, endIndent: 16),
                ],
              );
            }).toList(),
      ),
    );
  }
}

class _OptionItem {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? color;

  _OptionItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.color,
  });
}
