class Novel {
  final int id;
  final String title;
  final String author;
  final int categoryId;
  final String? categoryName;     // ← di‑join dari tabel categories
  final String status;            // draft / published
  final int chapterCount;
  final String? description;
  final String? coverUrl;
  final DateTime? publishedDate;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.categoryId,
    required this.status,
    required this.chapterCount,
    this.categoryName,
    this.description,
    this.coverUrl,
    this.publishedDate,
  });

  factory Novel.fromMap(Map<String, dynamic> map) => Novel(
        id: map['id'] as int,
        title: map['title'] as String,
        author: map['author'] as String,
        categoryId: map['category_id'] as int,
        categoryName: map['categories']?['name'] as String?, // hasil join
        status: map['status'] as String,
        chapterCount: (map['chapter_count'] ?? 0) as int,
        description: map['description'] as String?,
        coverUrl: map['cover_url'] as String?,
        publishedDate: map['published_date'] != null
            ? DateTime.parse(map['published_date'])
            : null,
      );

  Map<String, dynamic> toInsert() => {
        'title': title,
        'author': author,
        'description': description,
        'category_id': categoryId,
        'status': status,
        'chapter_count': chapterCount,
        'published_date': publishedDate?.toIso8601String(),
        'cover_url': coverUrl,
      };
}
