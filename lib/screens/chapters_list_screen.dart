import 'package:flutter/material.dart';

class ChaptersListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> chapters;

  const ChaptersListScreen({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Bab'),
        backgroundColor: Colors.deepPurple,
      ),
      body: ListView.separated(
        itemCount: chapters.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.deepPurple.shade100,
              child: Text('${index + 1}'),
            ),
            title: Text(
              chapter['title'] ?? 'Bab ${index + 1}',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.pushNamed(context, '/read', arguments: chapter);
            },
          );
        },
      ),
    );
  }
}
