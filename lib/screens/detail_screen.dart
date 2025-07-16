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
          Center(
            child: novel.coverUrl != null
                ? Image.network(novel.coverUrl!, height: 200)
                : Image.asset('assets/default_cover.png', height: 200),
          ),
          const SizedBox(height: 16),
          Text(novel.description ?? '-',
              style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 8),
          Text('Kategori: ${novel.categoryName ?? '-'}',
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
