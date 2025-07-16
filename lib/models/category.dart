class Category {
  final int id;
  final String name;
  final String? description;

  Category({
    required this.id,
    required this.name,
    this.description,
  });

  factory Category.fromMap(Map<String, dynamic> map) => Category(
        id: map['id'] as int,
        name: map['name'] as String,
        description: map['description'] as String?,
      );

  Map<String, dynamic> toInsert() => {
        'name': name,
        'description': description,
      };
}
