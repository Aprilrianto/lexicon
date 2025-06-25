import 'package:flutter/material.dart';
import '../models/novel.dart';

class DetailScreen extends StatelessWidget {
  final Novel novel;

  const DetailScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(novel.title),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Cover image
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

          // Title and author
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

          // Description
          Text(novel.description, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 20),

          // Metadata
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
