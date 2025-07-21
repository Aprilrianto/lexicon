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
  late int _currentViewCount;
  late double _currentAverageRating;
  late int _totalRatingsCount;
  bool _userHasRated = false;
  bool _userHasViewed = false;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    _currentViewCount = widget.novel.viewCount;
    _currentAverageRating = widget.novel.averageRating;
    _totalRatingsCount = widget.novel.totalRatings;
    _loadInitialStatus();
  }

  Future<void> _loadInitialStatus() async {
    setState(() {
      _isLoadingBookmark = true;
    });
    try {
      final userId = supabase.auth.currentUser?.id;
      if (userId == null) return;

      final bookmarkRes =
          await supabase
              .from('bookmarks')
              .select('id')
              .eq('user_id', userId)
              .eq('novel_id', widget.novel.id)
              .maybeSingle();
      final ratingRes =
          await supabase
              .from('ratings')
              .select('id')
              .eq('user_id', userId)
              .eq('novel_id', widget.novel.id)
              .maybeSingle();
      final viewRes =
          await supabase
              .from('novel_views')
              .select('id')
              .eq('user_id', userId)
              .eq('novel_id', widget.novel.id)
              .maybeSingle();

      if (mounted) {
        setState(() {
          _isBookmarked = bookmarkRes != null;
          _userHasRated = ratingRes != null;
          _userHasViewed = viewRes != null;
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
    final userId = supabase.auth.currentUser?.id;

    try {
      if (userId != null && !_userHasViewed) {
        await supabase.from('novel_views').insert({
          'user_id': userId,
          'novel_id': widget.novel.id,
        });

        if (mounted) {
          setState(() {
            _currentViewCount++;
            _userHasViewed = true;
          });
        }
      }

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
      if (e is PostgrestException && e.code == '23505') {
        debugPrint('User has already viewed this novel.');
        // Tetap lanjutkan membaca meskipun view sudah ada
        _continueReading();
      } else if (mounted) {
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

  // Fungsi terpisah untuk melanjutkan membaca jika view sudah ada
  void _continueReading() async {
    try {
      final response =
          await supabase
              .from('novels')
              .select('*, categories(name)')
              .eq('id', widget.novel.id)
              .single();
      final completeNovel = Novel.fromMap(response);
      if (mounted &&
          completeNovel.isi != null &&
          completeNovel.isi!.isNotEmpty) {
        Navigator.pushNamed(context, '/read', arguments: completeNovel);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Isi cerita untuk novel ini tidak tersedia.'),
          ),
        );
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _showRatingDialog() async {
    int? userRating;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Beri Rating Novel Ini'),
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(
                      Icons.star,
                      color:
                          (userRating ?? 0) >= index + 1
                              ? Colors.amber
                              : Colors.grey,
                    ),
                    onPressed: () {
                      setDialogState(() {
                        userRating = index + 1;
                      });
                    },
                  );
                }),
              ),
              actions: [
                TextButton(
                  child: const Text('Batal'),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                TextButton(
                  child: const Text('Kirim'),
                  onPressed: () {
                    if (userRating != null) {
                      _submitRating(userRating!);
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _submitRating(int rating) async {
    final userId = supabase.auth.currentUser?.id;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Anda harus login untuk memberi rating.')),
      );
      return;
    }

    try {
      await supabase.from('ratings').upsert({
        'user_id': userId,
        'novel_id': widget.novel.id,
        'rating': rating,
      }, onConflict: 'user_id, novel_id');

      final updatedNovelData =
          await supabase
              .from('novels')
              .select('average_rating, total_ratings')
              .eq('id', widget.novel.id)
              .single();
      if (mounted) {
        setState(() {
          _currentAverageRating =
              (updatedNovelData['average_rating'] as num?)?.toDouble() ?? 0.0;
          _totalRatingsCount = updatedNovelData['total_ratings'] ?? 0;
          _userHasRated = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Terima kasih atas rating Anda!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal mengirim rating: ${e.toString()}')),
        );
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
    String formatViews(int count) {
      if (count < 1000) return count.toString();
      return '${(count / 1000).toStringAsFixed(1)}K';
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          GestureDetector(
            onTap: _showRatingDialog,
            child: _StatItem(
              icon: Icons.star,
              value:
                  '${_currentAverageRating.toStringAsFixed(1)} ($_totalRatingsCount)',
              label: 'Rating',
              iconColor: _userHasRated ? Colors.amber : Colors.black87,
            ),
          ),
          _StatItem(
            icon: Icons.visibility,
            value: formatViews(_currentViewCount),
            label: 'Pembaca',
          ),
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
  final Color? iconColor;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: iconColor ?? Colors.black87, size: 28),
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
