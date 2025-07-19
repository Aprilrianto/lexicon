// screens/admin_dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  Map<String, dynamic>? _dashboardData;
  String? _adminUsername;
  String? _adminAvatarUrl;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  Future<void> _fetchDashboardData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;

      // Ambil profil admin saat ini
      final profileResponse =
          await supabase
              .from('profiles')
              .select('username, avatar_url')
              .eq('id', userId)
              .single();

      // DIPERBAIKI: Menggunakan .count() untuk mendapatkan jumlah data
      // Ambil total user aktif dan tidak aktif
      final activeUsersCount = await supabase
          .from('profiles')
          .count(CountOption.exact) // Menggunakan .count()
          .eq('is_active', true);

      final inactiveUsersCount = await supabase
          .from('profiles')
          .count(CountOption.exact) // Menggunakan .count()
          .eq('is_active', false);

      // Ambil total novel dan join dengan tabel categories untuk mendapatkan nama genre
      final novelsResponse = await supabase
          .from('novels')
          .select('id, categories(name)');

      // Proses data novel
      final totalNovels = novelsResponse.length;
      final Map<String, int> genreCounts = {};
      for (var novel in novelsResponse) {
        final category = novel['categories'];
        final genre =
            (category != null && category['name'] != null)
                ? category['name'] as String
                : 'Lainnya';
        genreCounts[genre] = (genreCounts[genre] ?? 0) + 1;
      }

      if (mounted) {
        setState(() {
          _adminUsername = profileResponse['username'] ?? 'Admin';
          _adminAvatarUrl = profileResponse['avatar_url'];

          _dashboardData = {
            'total_users': {
              // DIPERBAIKI: Langsung menggunakan hasil dari .count()
              'active': activeUsersCount,
              'inactive': inactiveUsersCount,
            },
            'total_novels': {'total': totalNovels, ...genreCounts},
          };
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat data dasbor: ${e.toString()}')),
        );
      }
    }
  }

  void _handleMenuSelection(String value) async {
    if (value == 'edit_profile') {
      await Navigator.pushNamed(context, '/edit-profile');
      _fetchDashboardData();
    } else if (value == 'logout') {
      await Supabase.instance.client.auth.signOut();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child:
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                  onRefresh: _fetchDashboardData,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 30),
                        _buildSectionTitle('Total User', 'Informasi Pengguna'),
                        const SizedBox(height: 16),
                        _buildUserStats(),
                        const SizedBox(height: 30),
                        _buildSectionTitle('Total Novel', 'Informasi Novel'),
                        const SizedBox(height: 16),
                        _buildNovelStats(),
                        const SizedBox(height: 30),
                        _buildGenreDistributionCard(),
                      ],
                    ),
                  ),
                ),
      ),
    );
  }

  // --- WIDGET BUILDERS (Tidak ada perubahan di sini) ---

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Welcome Back',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              _adminUsername ?? 'Admin Lexicon',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        PopupMenuButton<String>(
          onSelected: _handleMenuSelection,
          offset: const Offset(0, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'edit_profile',
                  child: ListTile(
                    leading: Icon(Icons.person_outline),
                    title: Text('Akun Saya'),
                  ),
                ),
                const PopupMenuDivider(),
                PopupMenuItem<String>(
                  value: 'logout',
                  child: ListTile(
                    leading: Icon(Icons.logout, color: Colors.red.shade400),
                    title: Text(
                      'Logout',
                      style: TextStyle(color: Colors.red.shade400),
                    ),
                  ),
                ),
              ],
          child: CircleAvatar(
            radius: 28,
            backgroundImage:
                _adminAvatarUrl != null && _adminAvatarUrl!.isNotEmpty
                    ? NetworkImage(_adminAvatarUrl!)
                    : null,
            child:
                _adminAvatarUrl == null || _adminAvatarUrl!.isEmpty
                    ? const Icon(Icons.person, size: 28)
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildUserStats() {
    final users =
        _dashboardData?['total_users'] ?? {'active': 0, 'inactive': 0};
    return Row(
      children: [
        Expanded(
          child: _InfoCard(
            title: 'Total User Aktif',
            value: users['active'].toString(),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _InfoCard(
            title: 'Total User Tidak Aktif',
            value: users['inactive'].toString(),
          ),
        ),
      ],
    );
  }

  Widget _buildNovelStats() {
    final novels =
        _dashboardData?['total_novels'] as Map<String, dynamic>? ??
        {'total': 0};
    final entries = novels.entries.toList();

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1.8,
      ),
      itemCount: entries.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final entry = entries[index];
        String title = 'Total Novel';
        if (entry.key != 'total') {
          title =
              'Genre ${entry.key[0].toUpperCase()}${entry.key.substring(1)}';
        }
        return _InfoCard(title: title, value: entry.value.toString());
      },
    );
  }

  Widget _buildGenreDistributionCard() {
    final novelStats =
        _dashboardData?['total_novels'] as Map<String, dynamic>? ?? {};
    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.pink.shade300,
      Colors.purple.shade300,
      Colors.teal.shade300,
    ];
    int colorIndex = 0;

    novelStats.forEach((key, value) {
      if (key != 'total' && value > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex % colors.length],
            value: (value as int).toDouble(),
            title: '',
            radius: 40,
          ),
        );
        colorIndex++;
      }
    });

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Distribusi Genre Novel',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Jumlah',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 150,
              child:
                  sections.isEmpty
                      ? const Center(child: Text("Tidak ada data genre"))
                      : PieChart(
                        PieChartData(
                          sections: sections,
                          centerSpaceRadius: 40,
                          sectionsSpace: 2,
                        ),
                      ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String value;

  const _InfoCard({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
