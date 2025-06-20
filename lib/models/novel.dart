class Novel {
  final int id;
  final String title;
  final String author;
  final String description;
  final String coverUrl;
  final String category; // Genre novel, misalnya: 'Fantasy', 'Romance'
  final String status; // 'Completed' atau 'On Going'
  final int chapterCount; // Total jumlah chapter
  final DateTime? publishedDate;

  Novel({
    required this.id,
    required this.title,
    required this.author,
    required this.description,
    required this.coverUrl,
    required this.category,
    required this.status,
    required this.chapterCount,
    this.publishedDate,
  });

  factory Novel.fromMap(Map<String, dynamic> m) => Novel(
    id: m['id'],
    title: m['title'] ?? '',
    author: m['author'] ?? '',
    description: m['description'] ?? '',
    coverUrl: m['cover_url'] ?? '',
    category: m['category'] ?? '',
    status: m['status'] ?? 'On Going',
    chapterCount: m['chapter_count'] ?? 0,
    publishedDate:
        m['published_date'] != null
            ? DateTime.parse(m['published_date'])
            : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'author': author,
    'description': description,
    'cover_url': coverUrl,
    'category': category,
    'status': status,
    'chapter_count': chapterCount,
    'published_date': publishedDate?.toIso8601String(),
  };
}
