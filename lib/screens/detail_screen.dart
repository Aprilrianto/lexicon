import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/novel.dart'; // Pastikan path ini benar

class DetailScreen extends StatefulWidget {
  final Novel novel;
  const DetailScreen({super.key, required this.novel});

  @override
  State<DetailScreen> createState() => _DetailScreenState();
}

class _DetailScreenState extends State<DetailScreen> {
  bool _isBookmarked = false;
  bool _isLoadingBookmark = true;
  bool _isLoadingReading = false;
  bool _isSynopsisExpanded = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _checkBookmarkStatus();
  }

  Future<void> _checkBookmarkStatus() async {
    setState(() {
      _isLoadingBookmark = true;
    });
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final response =
          await supabase
              .from('bookmarks')
              .select('id')
              .eq('user_id', userId)
              .eq('novel_id', widget.novel.id)
              .maybeSingle();

      if (mounted) {
        setState(() {
          _isBookmarked = response != null;
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBookmark = false;
        });
      }
    }
  }

  void _toggleBookmark() async {
    setState(() {
      _isLoadingBookmark = true;
    });
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk bookmark.')),
      );
      setState(() {
        _isLoadingBookmark = false;
      });
      return;
    }

    try {
      if (_isBookmarked) {
        await supabase.from('bookmarks').delete().match({
          'user_id': userId,
          'novel_id': widget.novel.id,
        });
      } else {
        await supabase.from('bookmarks').insert({
          'user_id': userId,
          'novel_id': widget.novel.id,
        });
      }

      if (mounted) {
        setState(() {
          _isBookmarked = !_isBookmarked;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isBookmarked
                  ? 'Novel ditambahkan ke bookmark'
                  : 'Novel dihapus dari bookmark',
            ),
            duration: const Duration(seconds: 1),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui bookmark: ${e.toString()}'),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingBookmark = false;
        });
      }
    }
  }

  void _startReading() async {
    setState(() {
      _isLoadingReading = true;
    });
    try {
      final response =
          await supabase
              .from('novels')
              .select('*, categories(name)')
              .eq('id', widget.novel.id)
              .single();

      final completeNovel = Novel.fromMap(response);

      if (mounted) {
        if (completeNovel.isi != null && completeNovel.isi!.isNotEmpty) {
          Navigator.pushNamed(context, '/read', arguments: completeNovel);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Isi cerita untuk novel ini tidak tersedia.'),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat isi cerita: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingReading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildCoverAndAuthorInfo(),
              const SizedBox(height: 24),
              _buildStatsCard(),
              const SizedBox(height: 24),
              _buildGenreTags(),
              const SizedBox(height: 24),
              _buildSynopsis(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildCoverAndAuthorInfo() {
    return Column(
      children: [
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child:
                widget.novel.coverUrl != null &&
                        widget.novel.coverUrl!.isNotEmpty
                    ? Image.network(
                      widget.novel.coverUrl!,
                      height: 220,
                      width: 150,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported,
                            size: 100,
                            color: Colors.grey,
                          ),
                    )
                    : Container(
                      height: 220,
                      width: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.book,
                        size: 80,
                        color: Colors.grey,
                      ),
                    ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          widget.novel.title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Text(
          'Penulis: ${widget.novel.author}',
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          widget.novel.publishedDate != null
              ? DateFormat('dd MMMM yyyy').format(widget.novel.publishedDate!)
              : 'Tanggal tidak diketahui',
          style: TextStyle(fontSize: 14, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(
            icon: Icons.visibility,
            value: '159K',
            label: 'Pembaca',
          ), // Placeholder
          _StatItem(
            icon: Icons.menu_book,
            value: widget.novel.chapterCount.toString(),
            label: 'Bab',
          ),
        ],
      ),
    );
  }

  Widget _buildGenreTags() {
    final category = widget.novel.categoryName;
    if (category == null || category.isEmpty) {
      return const SizedBox.shrink();
    }
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: [
        Chip(
          label: Text(category),
          backgroundColor: Colors.grey[200],
          labelStyle: const TextStyle(color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildSynopsis() {
    final synopsis = widget.novel.description ?? 'Tidak ada sinopsis.';
    final displayedSynopsis =
        !_isSynopsisExpanded && synopsis.length > 150
            ? '${synopsis.substring(0, 150)}...'
            : synopsis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Sinopsis',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        RichText(
          text: TextSpan(
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey[700],
              height: 1.5,
            ),
            children: [
              TextSpan(text: displayedSynopsis),
              if (synopsis.length > 150)
                TextSpan(
                  text:
                      _isSynopsisExpanded ? ' Sembunyikan' : ' Selengkapnya...',
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                  recognizer:
                      TapGestureRecognizer()
                        ..onTap = () {
                          setState(() {
                            _isSynopsisExpanded = !_isSynopsisExpanded;
                          });
                        },
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          OutlinedButton(
            onPressed: _isLoadingBookmark ? null : _toggleBookmark,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              side: BorderSide(color: Colors.grey.shade300),
            ),
            child:
                _isLoadingBookmark
                    ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                    : Icon(
                      _isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                      color: Colors.black87,
                    ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoadingReading ? null : _startReading,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 56),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoadingReading
                      ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                      : const Text(
                        'Mulai Baca',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.black87, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      ],
    );
  }
}
