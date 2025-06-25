import 'package:flutter/material.dart';

class ChaptersListScreen extends StatelessWidget {
  final List<Map<String, dynamic>> chapters;

  const ChaptersListScreen({super.key, required this.chapters});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Bab')),
      body: ListView.builder(
        itemCount: chapters.length,
        itemBuilder: (context, index) {
          final chapter = chapters[index];
          return ListTile(
            title: Text(chapter['title']),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.pushNamed(context, '/read', arguments: chapter);
            },
          );
        },
      ),
    );
  }
}
