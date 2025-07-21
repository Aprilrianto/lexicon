import 'package:flutter/material.dart';
import '../models/novel.dart';

class NovelCard extends StatelessWidget {
  final Novel novel;
  final VoidCallback onTap;
  const NovelCard({super.key, required this.novel, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      // Memberikan bayangan halus dan bentuk yang rapi
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior:
          Clip.antiAlias, // Memastikan konten di dalam card mengikuti bentuk rounded
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Gambar sampul dibuat fleksibel dengan Expanded agar tidak terpotong
            Expanded(
              child: Container(
                width: double.infinity,
                color:
                    Colors
                        .grey[200], // Warna latar belakang jika gambar gagal dimuat
                child:
                    novel.coverUrl != null && novel.coverUrl!.isNotEmpty
                        ? Image.network(
                          novel.coverUrl!,
                          fit: BoxFit.cover,
                          // Menangani error jika gambar tidak bisa dimuat
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.image_not_supported,
                              color: Colors.grey,
                            );
                          },
                        )
                        : const Icon(Icons.book, size: 50, color: Colors.grey),
              ),
            ),
            // Area teks dengan padding yang rapi
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    novel.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    novel.author,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
