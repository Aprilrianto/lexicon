import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';
import '../models/novel.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // _currentIndex sekarang akan mengontrol tab yang aktif di BottomAppBar
  int _currentIndex = 0;
  List<Category> categories = [];
  List<Novel> novels = [];
  bool isLoadingCategories = true;
  bool isLoadingNovels = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
    fetchNovels();
  }

  Future<void> fetchCategories() async {
    try {
      final response =
          await Supabase.instance.client.from('categories').select();
      if (mounted) {
        setState(() {
          categories =
              (response as List).map((e) => Category.fromMap(e)).toList();
          isLoadingCategories = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchNovels() async {
    try {
      final response = await Supabase.instance.client.from('novels').select();
      if (mounted) {
        setState(() {
          novels = (response as List).map((e) => Novel.fromMap(e)).toList();
          isLoadingNovels = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching novels: $e');
    }
  }

  List<Novel> get filteredNovels {
    if (searchQuery.isEmpty) return novels;
    return novels.where((novel) {
      return novel.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
          novel.author.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
  }

  // Fungsi untuk menangani tap pada item di BottomAppBar
  void _onTabTapped(int index) {
    // Logika navigasi disesuaikan dengan item baru
    // 0: Beranda, 1: Eksplor, 2: Koleksiku, 3: Profil
    if (index == 2) {
      Navigator.pushNamed(context, '/bookmarks');
    } else if (index == 3) {
      Navigator.pushNamed(context, '/profile');
    } else {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  // Widget untuk membuat item navigasi bawah agar tidak duplikat kode
  Widget _buildBottomNavItem(IconData icon, String label, int index) {
    final isSelected = _currentIndex == index;
    return IconButton(
      icon: Icon(
        icon,
        color: isSelected ? Colors.deepPurple : Colors.grey,
        size: 28,
      ),
      onPressed: () => _onTabTapped(index),
      tooltip: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lexicon',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none_outlined, size: 28),
            onPressed: () {
              // Aksi untuk notifikasi
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari judul, penulis, atau genre',
                  prefixIcon: const Icon(Icons.search),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) {
                  setState(() {
                    searchQuery = val;
                  });
                },
              ),
            ),

            // Kategori
            SizedBox(
              height: 45,
              child:
                  isLoadingCategories
                      ? const Center(
                        child: CircularProgressIndicator.adaptive(),
                      )
                      : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Chip(
                              label: Text(category.name),
                              backgroundColor: Colors.deepPurple.shade50,
                              side: BorderSide(
                                color: Colors.deepPurple.shade100,
                              ),
                              labelStyle: TextStyle(
                                color: Colors.deepPurple.shade900,
                              ),
                            ),
                          );
                        },
                      ),
            ),

            const SizedBox(height: 12),

            // List Novel
            Expanded(
              child:
                  isLoadingNovels
                      ? const Center(child: CircularProgressIndicator())
                      : GridView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.6,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                        itemCount: filteredNovels.length,
                        itemBuilder: (context, index) {
                          final novel = filteredNovels[index];
                          return GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => DetailScreen(novel: novel),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.asset(
                                    'assets/default_cover.png', // Pastikan path ini benar
                                    height: 160,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  novel.title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  novel.author,
                                  style: const TextStyle(color: Colors.grey),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Aksi untuk menambah novel baru
        },
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      // INI BAGIAN YANG SUDAH DIPERBAIKI
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            _buildBottomNavItem(Icons.home_outlined, 'Beranda', 0),
            _buildBottomNavItem(Icons.explore_outlined, 'Eksplor', 1),
            const SizedBox(width: 48), // Ruang untuk FloatingActionButton
            _buildBottomNavItem(Icons.bookmark_border, 'Koleksiku', 2),
            _buildBottomNavItem(Icons.person_outline, 'Profil', 3),
          ],
        ),
      ),
    );
  }
}
