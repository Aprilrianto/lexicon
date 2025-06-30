class Category {
  final int id;
  final String name;
  final String? description;
  final List<int>? novelIds;

  Category({
    required this.id,
    required this.name,
    this.description,
    this.novelIds,
  });

  factory Category.fromMap(Map<String, dynamic> m) => Category(
    id: m['id'],
    name: m['name'] ?? '',
    description: m['description'],
    novelIds: m['novel_ids'] != null ? List<int>.from(m['novel_ids']) : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'novel_ids': novelIds,
  };
}
