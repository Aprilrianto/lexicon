import 'package:flutter/material.dart';
import '../models/novel.dart'; // Pastikan path ini benar

class ChapterReadScreen extends StatelessWidget {
  final Novel novel;
  const ChapterReadScreen({super.key, required this.novel});

  @override
  Widget build(BuildContext context) {
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
          novel.title,
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
          // Menampilkan isi cerita dari model Novel
          novel.isi ?? 'Konten tidak tersedia.',
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
