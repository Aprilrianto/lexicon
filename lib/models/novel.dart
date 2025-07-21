// models/novel.dart

class Novel {
  final int id;
  final String title;
  final String author;
  final String? description;
  final String? coverUrl;
  final DateTime? publishedDate;
  final int? categoryId;
  final String? categoryName;
  final String? status;
  final int chapterCount;
  final String? isi;
  final int viewCount;
  final double averageRating;
  final int totalRatings; // DITAMBAHKAN: Properti untuk total perating

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
    required this.averageRating,
    required this.totalRatings, // DITAMBAHKAN
  });

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
      categoryName: (map['categories'] as Map<String, dynamic>?)?['name'],
      status: map['status'],
      chapterCount: map['chapter_count'] ?? 0,
      isi: map['isi'],
      viewCount: map['view_count'] ?? 0,
      averageRating: (map['average_rating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: map['total_ratings'] ?? 0, // DITAMBAHKAN
    );
  }

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
    'average_rating': averageRating,
    'total_ratings': totalRatings,
  };
}
