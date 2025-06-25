import 'package:flutter/material.dart';
import '../models/novel.dart';
import 'chapters_list_screen.dart';

class DetailScreen extends StatelessWidget {
  final Novel novel;

  const DetailScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    // Contoh data bab. Ini nanti bisa di-fetch dari Supabase.
    final List<Map<String, dynamic>> chapters = [
      {'title': 'Bab 1: Awal', 'content': 'Isi bab 1...'},
      {'title': 'Bab 2: Konflik', 'content': 'Isi bab 2...'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(novel.title),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.bookmark),
            tooltip: 'Lihat Koleksi',
            onPressed: () {
              Navigator.pushNamed(context, '/bookmarks');
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              novel.coverUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder:
                  (context, error, stackTrace) =>
                      const Icon(Icons.broken_image, size: 100),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            novel.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'by ${novel.author}',
            style: const TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          Text(novel.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildTag('Kategori', novel.category),
              _buildTag('Status', novel.status),
              _buildTag('Chapter', novel.chapterCount.toString()),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            'Tanggal Terbit: ${novel.publishedDate?.toLocal().toString().split(' ')[0] ?? '-'}',
            style: const TextStyle(fontSize: 14, color: Colors.black54),
          ),
          const SizedBox(height: 30),

          // Tombol Navigasi
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.menu_book),
                  label: const Text('Baca Bab'),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChaptersListScreen(chapters: chapters),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.bookmark),
                  label: const Text('Koleksiku'),
                  onPressed: () {
                    Navigator.pushNamed(context, '/bookmarks');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple.shade200,
                    foregroundColor: Colors.black,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.deepPurple.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.deepPurple,
            ),
          ),
        ),
      ],
    );
  }
}
