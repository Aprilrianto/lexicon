import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/novel.dart';
import '../widgets/novel_card.dart';
import 'detail_screen.dart';
import 'novel_form_screen.dart'; // Impor form screen
import 'write_story_screen.dart'; // Impor write screen

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
      final response = await Supabase.instance.client
          .from('novels')
          .select('*, categories(name)')
          .eq('user_id', user.id)
          .order('published_date', ascending: false);

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

  void _showWorkOptions(BuildContext context, Novel novel) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        if (novel.status == 'draft') {
          return _buildDraftOptions(ctx, novel);
        } else {
          return _buildPublishedOptions(ctx, novel);
        }
      },
    );
  }

  Widget _buildDraftOptions(BuildContext ctx, Novel novel) {
    return Wrap(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.drive_file_rename_outline),
          title: const Text('Lanjutkan Menulis'),
          onTap: () async {
            Navigator.pop(ctx);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WriteStoryScreen(novelId: novel.id),
              ),
            );
            _refreshWorks();
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit_document),
          title: const Text('Edit Detail Novel'),
          onTap: () async {
            Navigator.pop(ctx);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NovelFormScreen(existingNovel: novel),
              ),
            );
            _refreshWorks();
          },
        ),
        ListTile(
          leading: const Icon(Icons.public, color: Colors.green),
          title: const Text(
            'Publikasikan',
            style: TextStyle(color: Colors.green),
          ),
          onTap:
              () => _updateStatus(
                ctx,
                novel.id,
                'published',
                'Novel berhasil dipublikasikan!',
              ),
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('Hapus Draft', style: TextStyle(color: Colors.red)),
          onTap: () => _deleteNovel(ctx, novel.id, 'Draft berhasil dihapus!'),
        ),
      ],
    );
  }

  Widget _buildPublishedOptions(BuildContext ctx, Novel novel) {
    return Wrap(
      children: <Widget>[
        ListTile(
          leading: const Icon(Icons.visibility_outlined),
          title: const Text('Lihat Detail Publik'),
          onTap: () {
            Navigator.pop(ctx);
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => DetailScreen(novel: novel)),
            );
          },
        ),
        ListTile(
          leading: const Icon(Icons.edit_document),
          title: const Text('Edit Detail Novel'),
          onTap: () async {
            Navigator.pop(ctx);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => NovelFormScreen(existingNovel: novel),
              ),
            );
            _refreshWorks();
          },
        ),
        // DITAMBAHKAN: Opsi untuk mengedit isi cerita novel yang sudah publik
        ListTile(
          leading: const Icon(Icons.drive_file_rename_outline),
          title: const Text('Edit Isi Cerita'),
          onTap: () async {
            Navigator.pop(ctx);
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WriteStoryScreen(novelId: novel.id),
              ),
            );
            _refreshWorks();
          },
        ),
        ListTile(
          leading: const Icon(Icons.drafts_outlined, color: Colors.orange),
          title: const Text(
            'Kembalikan ke Draft',
            style: TextStyle(color: Colors.orange),
          ),
          onTap:
              () => _updateStatus(
                ctx,
                novel.id,
                'draft',
                'Novel dikembalikan ke draft.',
              ),
        ),
        ListTile(
          leading: const Icon(Icons.delete_outline, color: Colors.red),
          title: const Text('Hapus Novel', style: TextStyle(color: Colors.red)),
          onTap: () => _deleteNovel(ctx, novel.id, 'Novel berhasil dihapus!'),
        ),
      ],
    );
  }

  Future<void> _updateStatus(
    BuildContext ctx,
    int novelId,
    String newStatus,
    String message,
  ) async {
    try {
      await Supabase.instance.client
          .from('novels')
          .update({'status': newStatus})
          .eq('id', novelId);
      Navigator.pop(ctx);
      _refreshWorks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _deleteNovel(
    BuildContext ctx,
    int novelId,
    String message,
  ) async {
    try {
      await Supabase.instance.client.from('novels').delete().eq('id', novelId);
      Navigator.pop(ctx);
      _refreshWorks();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      // Handle error
    }
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
                      onTap: () {
                        _showWorkOptions(context, novel);
                      },
                    ),
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
