import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/novel.dart';
import '../widgets/novel_card.dart';
import 'detail_screen.dart';
// import 'novel_form_screen.dart'; // Uncomment jika ingin ada tombol edit

class MyWorksScreen extends StatefulWidget {
  const MyWorksScreen({super.key});

  @override
  State<MyWorksScreen> createState() => _MyWorksScreenState();
}

class _MyWorksScreenState extends State<MyWorksScreen> {
  late Future<List<Novel>> _myNovelsFuture;

  @override
  void initState() {
    super.initState();
    _myNovelsFuture = _fetchMyNovels();
  }

  Future<List<Novel>> _fetchMyNovels() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return [];

    try {
      // DIPERBAIKI: Mengurutkan berdasarkan 'published_date'
      final response = await Supabase.instance.client
          .from('novels')
          .select('*, categories(name)')
          .eq('user_id', user.id)
          .order(
            'published_date',
            ascending: false,
          ); // Menggunakan kolom yang ada

      return (response as List)
          .map((item) => Novel.fromMap(item as Map<String, dynamic>))
          .toList();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat karya: ${e.toString()}')),
        );
      }
      return [];
    }
  }

  void _refreshWorks() {
    setState(() {
      _myNovelsFuture = _fetchMyNovels();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Karya Saya')),
      body: FutureBuilder<List<Novel>>(
        future: _myNovelsFuture,
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
                'Anda belum membuat karya apapun.',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          final novels = snapshot.data!;
          return RefreshIndicator(
            onRefresh: () async => _refreshWorks(),
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
                return Stack(
                  children: [
                    NovelCard(
                      novel: novel,
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => DetailScreen(novel: novel),
                          ),
                        );
                        _refreshWorks();
                      },
                    ),
                    // Menambahkan label status "Draft"
                    if (novel.status == 'draft')
                      Positioned(
                        top: 8,
                        left: 8,
                        child: Chip(
                          label: const Text('Draft'),
                          backgroundColor: Colors.grey.shade600,
                          labelStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                          ),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                );
              },
            ),
          );
        },
      ),
    );
  }
}
