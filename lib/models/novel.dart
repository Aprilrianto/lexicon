// models/novel.dart

class Novel {
  final int id;
  final String title;
  final String author;
  final String? description;
  final String? coverUrl;
  final DateTime? publishedDate;
  final int? categoryId;
  final String? categoryName; // Dari join dengan tabel categories
  final String? status; // 'draft' atau 'published'
  final int chapterCount;
  final String? isi; // Isi cerita lengkap
  final int viewCount; // Jumlah pembaca

  Novel({
    required this.id,
    required this.title,
    required this.author,
    this.description,
    this.coverUrl,
    this.publishedDate,
    this.categoryId,
    this.categoryName,
    this.status,
    required this.chapterCount,
    this.isi,
    required this.viewCount,
  });

  // Factory constructor yang disempurnakan untuk membuat objek Novel dari data Supabase
  factory Novel.fromMap(Map<String, dynamic> map) {
    return Novel(
      id: map['id'] ?? 0,
      title: map['title'] ?? 'Tanpa Judul',
      author: map['author'] ?? 'Anonim',
      description: map['description'],
      coverUrl: map['cover_url'],
      publishedDate:
          map['published_date'] != null
              ? DateTime.tryParse(map['published_date'])
              : null,
      categoryId: map['category_id'],
      // Mengambil nama kategori dari relasi, jika ada
      categoryName: (map['categories'] as Map<String, dynamic>?)?['name'],
      status: map['status'],
      chapterCount: map['chapter_count'] ?? 0,
      isi: map['isi'],
      viewCount: map['view_count'] ?? 0,
    );
  }

  // Method untuk mengubah objek menjadi Map, berguna untuk INSERT/UPDATE
  Map<String, dynamic> toMap() => {
    'title': title,
    'author': author,
    'description': description,
    'category_id': categoryId,
    'status': status,
    'chapter_count': chapterCount,
    'published_date': publishedDate?.toIso8601String(),
    'cover_url': coverUrl,
    'isi': isi,
    'view_count': viewCount,
  };
}
