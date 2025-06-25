import 'package:flutter/material.dart';
import '../models/novel.dart';

class DetailScreen extends StatelessWidget {
  final Novel novel;

  const DetailScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(novel.title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Image.network(novel.coverUrl, height: 200, fit: BoxFit.cover),
            const SizedBox(height: 16),
            Text(
              novel.title,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              'by ${novel.author}',
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
            const SizedBox(height: 12),
            Text(novel.description),
            const SizedBox(height: 16),
            Text('Kategori: ${novel.category}'),
            Text('Status: ${novel.status}'),
            Text('Chapter: ${novel.chapterCount}'),
            Text(
              'Terbit: ${novel.publishedDate?.toLocal().toString().split(' ')[0]}',
            ),
          ],
        ),
      ),
    );
  }
}
