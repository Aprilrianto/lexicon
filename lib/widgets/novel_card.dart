import 'package:flutter/material.dart';
import '../models/novel.dart';

class NovelCard extends StatelessWidget {
  final Novel novel;
  final VoidCallback onTap;
  const NovelCard({super.key, required this.novel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: novel.coverUrl != null
                ? Image.network(novel.coverUrl!,
                    height: 160, width: double.infinity, fit: BoxFit.cover)
                : Image.asset('assets/default_cover.png',
                    height: 160, width: double.infinity, fit: BoxFit.cover),
          ),
          const SizedBox(height: 8),
          Text(
            novel.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Text(novel.author, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}
