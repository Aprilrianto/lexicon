import 'package:flutter/material.dart';
import '../models/novel.dart';

class DetailScreen extends StatelessWidget {
  final Novel novel;
  const DetailScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(novel.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // COVER
          Center(
            child: novel.coverUrl != null
                ? Image.network(novel.coverUrl!, height: 200)
                : Image.asset('assets/default_cover.png', height: 200),
          ),
          const SizedBox(height: 12),

          // JUDUL
          Center(
            child: Text(
              novel.title,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // KATEGORI + PENULIS
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Kategori: ${novel.categoryName ?? '-'}',
                style: const TextStyle(color: Colors.grey),
              ),
              Text(
                'Penulis: ${novel.author}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // SINOPSIS
          const Text(
            'Sinopsis',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            novel.description ?? '-',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 16),

          // ISI CERITA
          const Text(
            'Isi Cerita',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            novel.isi,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
