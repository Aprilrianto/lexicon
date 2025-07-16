import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';
import '../models/novel.dart';
import '../widgets/novel_card.dart';
import 'novel_form_screen.dart';
import 'detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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
      final res = await Supabase.instance.client.from('categories').select();
      setState(() {
        categories = (res as List<dynamic>)
            .map((e) => Category.fromMap(e as Map<String, dynamic>))
            .toList();
        isLoadingCategories = false;
      });
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> fetchNovels() async {
    try {
      final res = await Supabase.instance.client
          .from('novels')
          .select('*, categories(name)');
      setState(() {
        novels = (res as List<dynamic>)
            .map((e) => Novel.fromMap(e as Map<String, dynamic>))
            .toList();
        isLoadingNovels = false;
      });
    } catch (e) {
      debugPrint('Error fetching novels: $e');
    }
  }

  List<Novel> get filteredNovels {
    if (searchQuery.isEmpty) return novels;
    return novels.where((n) {
      final q = searchQuery.toLowerCase();
      return n.title.toLowerCase().contains(q) ||
          n.author.toLowerCase().contains(q);
    }).toList();
  }

  void _onTabTapped(int idx) {
    if (idx == 2) {
      Navigator.pushNamed(context, '/bookmarks');
    } else if (idx == 3) {
      Navigator.pushNamed(context, '/profile');
    } else {
      setState(() => _currentIndex = idx);
    }
  }

  Widget _bottomItem(IconData icon, String label, int idx) {
    final sel = _currentIndex == idx;
    return IconButton(
      icon: Icon(icon, color: sel ? Colors.deepPurple : Colors.grey, size: 28),
      onPressed: () => _onTabTapped(idx),
      tooltip: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Lexicon',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        foregroundColor: Colors.deepPurple,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Cari judul / penulis',
                  prefixIcon: const Icon(Icons.search),
                  fillColor: Colors.grey.shade200,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (v) => setState(() => searchQuery = v),
              ),
            ),
            SizedBox(
              height: 45,
              child: isLoadingCategories
                  ? const Center(child: CircularProgressIndicator.adaptive())
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      scrollDirection: Axis.horizontal,
                      itemCount: categories.length,
                      itemBuilder: (_, i) => Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Chip(label: Text(categories[i].name)),
                      ),
                    ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: isLoadingNovels
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
                      itemBuilder: (_, i) => NovelCard(
                        novel: filteredNovels[i],
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  DetailScreen(novel: filteredNovels[i]),
                            ),
                          );
                          fetchNovels();
                        },
                      ),
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
        onPressed: () async {
          final saved = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NovelFormScreen()),
          );
          if (saved == true) fetchNovels();
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8,
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _bottomItem(Icons.home_outlined, 'Beranda', 0),
            _bottomItem(Icons.explore_outlined, 'Eksplor', 1),
            const SizedBox(width: 48),
            _bottomItem(Icons.bookmark_border, 'Koleksiku', 2),
            _bottomItem(Icons.person_outline, 'Profil', 3),
          ],
        ),
      ),
    );
  }
}
