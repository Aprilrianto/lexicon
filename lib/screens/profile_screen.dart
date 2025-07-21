import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'edit_profile_screen.dart';
import 'settings_screen.dart';
import 'my_works_screen.dart';
import 'help_and_feedback_screen.dart';

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

  // DITAMBAHKAN: Fungsi untuk menampilkan dialog konfirmasi logout
  Future<void> _showLogoutConfirmationDialog() async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari akun Anda?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _logout(); // Lanjutkan proses logout
              },
            ),
          ],
        );
      },
    );
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
          final bio = profile["bio"];

          return RefreshIndicator(
            onRefresh: () async => _refreshProfile(),
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                _buildProfileHeader(context, avatarUrl, username, bio),
                const SizedBox(height: 20),
                _buildOptionSection([
                  _OptionItem(
                    icon: Icons.edit_note_outlined,
                    title: 'Karya Saya',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MyWorksScreen(),
                        ),
                      );
                    },
                  ),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HelpAndFeedbackScreen(),
                        ),
                      );
                    },
                  ),
                  _OptionItem(
                    icon: Icons.logout,
                    title: 'Logout',
                    // DIUBAH: onTap sekarang memanggil dialog konfirmasi
                    onTap: _showLogoutConfirmationDialog,
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
                        item.onTap != _logout &&
                                item.onTap != _showLogoutConfirmationDialog
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
