class Chapter {
  final int id;
  final int novelId;
  final String title;
  final String content;
  final DateTime createdAt;

  Chapter({
    required this.id,
    required this.novelId,
    required this.title,
    required this.content,
    required this.createdAt,
  });

  factory Chapter.fromMap(Map<String, dynamic> json) => Chapter(
        id: json['id'],
        novelId: json['novel_id'],
        title: json['title'],
        content: json['content'],
        createdAt: DateTime.parse(json['created_at']),
      );

  Map<String, dynamic> toInsert() => {
        'novel_id': novelId,
        'title': title,
        'content': content,
      };
}
