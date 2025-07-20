import 'package:flutter/material.dart';
import '../models/novel.dart'; // Impor model Novel

class ChapterReadScreen extends StatelessWidget {
  // Menerima objek Novel
  final Novel novel;
  const ChapterReadScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
    // Mengambil judul dan konten dari objek Novel
    final title = novel.title;
    final content = novel.isi ?? 'Konten tidak tersedia.';

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
