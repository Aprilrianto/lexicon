// screens/bookmark_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/novel.dart'; // Pastikan path ini benar
import '../widgets/novel_card.dart'; // Widget untuk menampilkan novel
import 'detail_screen.dart';

class BookmarkScreen extends StatefulWidget {
  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() => _BookmarkScreenState();
}

class _BookmarkScreenState extends State<BookmarkScreen> {
  late Future<List<Novel>> _bookmarkedNovelsFuture;

  @override
  void initState() {
    super.initState();
    _bookmarkedNovelsFuture = _fetchBookmarkedNovels();
  }

  Future<List<Novel>> _fetchBookmarkedNovels() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      // Jika tidak ada user, kembalikan list kosong
      return [];
    }

    try {
      // Mengambil data dari tabel bookmarks dan melakukan join dengan tabel novels
      final response = await Supabase.instance.client
          .from('bookmarks')
          .select(
            'novels(*, categories(name))',
          ) // Ambil semua data dari novel dan nama kategori
          .eq('user_id', user.id);

      // Ubah hasil query menjadi List<Novel>
      final novels =
          (response as List<dynamic>)
              .map(
                (item) => Novel.fromMap(item['novels'] as Map<String, dynamic>),
              )
              .toList();
      return novels;
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat bookmark: ${e.toString()}')),
        );
      }
      return [];
    }
  }

  // Fungsi untuk memuat ulang data
  void _refreshBookmarks() {
    setState(() {
      _bookmarkedNovelsFuture = _fetchBookmarkedNovels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Koleksiku'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: FutureBuilder<List<Novel>>(
        future: _bookmarkedNovelsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Terjadi kesalahan: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Anda belum memiliki bookmark.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final novels = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshBookmarks(),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: novels.length,
              itemBuilder: (context, index) {
                final novel = novels[index];
                return NovelCard(
                  novel: novel,
                  onTap: () async {
                    // Navigasi ke detail dan muat ulang setelah kembali
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailScreen(novel: novel),
                      ),
                    );
                    _refreshBookmarks();
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
