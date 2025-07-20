import 'package:flutter/material.dart';

class ChapterReadScreen extends StatelessWidget {
  // Menerima Map<String, dynamic> yang berisi data satu bab
  final Map<String, dynamic> chapter;
  const ChapterReadScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    // Mengambil judul dan konten dari data bab yang diterima
    final title = chapter['title'] as String? ?? 'Judul Bab';
    final content = chapter['content'] as String? ?? 'Konten tidak tersedia.';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: SelectableText(
          content,
          style: const TextStyle(
            fontSize: 16,
            height: 1.6, // Jarak antar baris untuk kenyamanan membaca
            color: Colors.black87,
          ),
          textAlign: TextAlign.justify,
        ),
      ),
    );
  }
}
