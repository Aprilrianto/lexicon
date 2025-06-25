import 'package:flutter/material.dart';

class ChapterReadScreen extends StatelessWidget {
  final Map<String, dynamic> chapter;

  const ChapterReadScreen({super.key, required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(chapter['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(child: Text(chapter['content'])),
      ),
    );
  }
}
