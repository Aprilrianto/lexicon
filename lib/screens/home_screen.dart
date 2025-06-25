import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/novel.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  List<Novel> trendingNovels = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchNovels();
  }

  Future<void> fetchNovels() async {
    try {
      final response = await Supabase.instance.client.from('novels').select();
      setState(() {
        trendingNovels =
            (response as List).map((map) => Novel.fromMap(map)).toList();
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      debugPrint('Error fetching novels: $e');
    }
  }

  void _onTabTapped(int index) {
    if (index == 4) {
      Navigator.pushNamed(context, '/profile');
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Lexicon',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                IconButton(icon: const Icon(Icons.menu), onPressed: () {}),
              ],
            ),

            // Search bar
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                decoration: InputDecoration(
                  hintText: 'Cari judul, penulis, atau genre',
                  border: InputBorder.none,
                  icon: Icon(Icons.search),
                ),
              ),
            ),

            // Genre chips
            Wrap(
              spacing: 8,
              children: const [
                Chip(label: Text('Fantasi')),
                Chip(label: Text('Romantis')),
                Chip(label: Text('Misteri')),
                Chip(label: Text('Fiksi Ilmiah')),
              ],
            ),

            const SizedBox(height: 20),

            _buildSectionHeader('Trending Minggu Ini'),
            _buildBookList(),

            const SizedBox(height: 20),

            _buildSectionHeader('Yang mungkin kamu suka'),
            _buildBookList(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Beranda'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Eksplor'),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark),
            label: 'Koleksiku',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          TextButton(onPressed: () {}, child: const Text('Tampilkan Semua')),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (trendingNovels.isEmpty) {
      return const Text('Tidak ada novel yang tersedia.');
    }

    return SizedBox(
      height: 170,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: trendingNovels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final novel = trendingNovels[index];
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailScreen(novel: novel)),
              );
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 100,
                  height: 120,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(novel.coverUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  novel.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  'by ${novel.author}',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
