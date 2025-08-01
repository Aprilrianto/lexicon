import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/category.dart';
import '../models/novel.dart';
import '../widgets/novel_card.dart';
import 'novel_form_screen.dart';
import 'detail_screen.dart';
import 'notification_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _bottomNavIndex = 0;
  int? _selectedCategoryId;

  List<Category> _categories = [];
  List<Novel> _novels = [];
  List<Novel> _filteredNovels = [];

  bool _isLoading = true;
  String _searchQuery = '';
  bool _hasNotification = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    // Tidak perlu setState di sini karena FutureBuilder akan menangani loading state
    await _fetchCategories();
    await _fetchNovels();
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _fetchCategories() async {
    try {
      final res = await Supabase.instance.client.from('categories').select();
      if (mounted) {
        setState(() {
          _categories =
              (res as List)
                  .map((e) => Category.fromMap(e as Map<String, dynamic>))
                  .toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
    }
  }

  Future<void> _fetchNovels() async {
    try {
      final res = await Supabase.instance.client
          .from('novels')
          .select('*, categories(name)')
          .eq('status', 'published');

      if (mounted) {
        setState(() {
          _novels =
              (res as List)
                  .map((e) => Novel.fromMap(e as Map<String, dynamic>))
                  .toList();
          _applyFilters();
        });
      }
    } catch (e) {
      debugPrint('Error fetching novels: $e');
    }
  }

  void _applyFilters() {
    List<Novel> tempNovels = List.from(_novels);

    if (_selectedCategoryId != null) {
      tempNovels =
          tempNovels.where((novel) {
            return novel.categoryId == _selectedCategoryId;
          }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      tempNovels =
          tempNovels.where((n) {
            return n.title.toLowerCase().contains(q) ||
                n.author.toLowerCase().contains(q);
          }).toList();
    }

    setState(() {
      _filteredNovels = tempNovels;
    });
  }

  void _onCategoryTap(int categoryId) {
    setState(() {
      if (_selectedCategoryId == categoryId) {
        _selectedCategoryId = null;
      } else {
        _selectedCategoryId = categoryId;
      }
      _applyFilters();
    });
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query;
      _applyFilters();
    });
  }

  void _onBottomNavTapped(int idx) {
    if (idx == 1) {
      Navigator.pushNamed(context, '/explore');
    } else if (idx == 2) {
      Navigator.pushNamed(context, '/bookmarks');
    } else if (idx == 3) {
      Navigator.pushNamed(context, '/profile');
    } else {
      setState(() => _bottomNavIndex = idx);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Lexicon',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        foregroundColor: Colors.black, // Warna dikembalikan
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: Colors.black54,
                  size: 28,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationScreen(),
                    ),
                  );
                },
                tooltip: 'Notifikasi',
              ),
              if (_hasNotification)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    constraints: const BoxConstraints(
                      minWidth: 12,
                      minHeight: 12,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchData, // Fungsi refresh dipanggil di sini
          child: Column(
            children: [
              _buildSearchBar(),
              _buildCategoryChips(),
              const SizedBox(height: 12),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredNovels.isEmpty
                        ? const Center(child: Text('Novel tidak ditemukan.'))
                        : _buildNovelGrid(),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black, // Warna dikembalikan
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 32),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NovelFormScreen()),
          );
          if (result == true && mounted) {
            _fetchData();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _buildBottomAppBar(),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'Cari judul atau penulis',
          prefixIcon: const Icon(Icons.search),
          fillColor: Colors.grey.shade200,
          filled: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onChanged: _onSearchChanged,
      ),
    );
  }

  Widget _buildCategoryChips() {
    return SizedBox(
      height: 45,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        itemBuilder: (_, i) {
          final category = _categories[i];
          final isSelected = _selectedCategoryId == category.id;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category.name),
              selected: isSelected,
              onSelected: (_) => _onCategoryTap(category.id),
              selectedColor: Colors.black, // Warna dikembalikan
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
              ),
              backgroundColor: Colors.grey.shade200,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNovelGrid() {
    return GridView.builder(
      // Menambahkan physics agar bisa di-scroll bahkan saat item sedikit
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.6,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: _filteredNovels.length,
      itemBuilder:
          (_, i) => NovelCard(
            novel: _filteredNovels[i],
            onTap: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(novel: _filteredNovels[i]),
                ),
              );
              _fetchNovels();
            },
          ),
    );
  }

  Widget _buildBottomAppBar() {
    return BottomAppBar(
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
    );
  }

  Widget _bottomItem(IconData icon, String label, int idx) {
    final sel = _bottomNavIndex == idx;
    return IconButton(
      icon: Icon(
        icon,
        color: sel ? Colors.black : Colors.grey,
        size: 28,
      ), // Warna dikembalikan
      onPressed: () => _onBottomNavTapped(idx),
      tooltip: label,
    );
  }
}
