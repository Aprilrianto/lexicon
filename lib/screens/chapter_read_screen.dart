import 'package:flutter/material.dart';

class ChapterReadScreen extends StatelessWidget {
  final Map<String, dynamic> chapter;

  const ChapterReadScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    final String title = chapter['title'] ?? 'Bab';
    final String content = chapter['content'] ?? 'Konten tidak tersedia.';

    return Scaffold(
      appBar: AppBar(title: Text(title), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Text(
            content,
            style: const TextStyle(fontSize: 16, height: 1.6),
          ),
        ),
      ),
    );
  }
}
