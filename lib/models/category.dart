class Category {
  final int id;
  final String name;
  final String? description; // opsional jika deskripsi kategori diperlukan
  final String? iconUrl; // opsional jika icon kategori ingin ditampilkan
  final List<int>?
  novelIds; // daftar ID novel yang tergolong dalam kategori ini

  Category({
    required this.id,
    required this.name,
    this.description,
    this.iconUrl,
    this.novelIds,
  });

  factory Category.fromMap(Map<String, dynamic> m) => Category(
    id: m['id'],
    name: m['name'] ?? '',
    description: m['description'],
    iconUrl: m['icon_url'],
    novelIds: m['novel_ids'] != null ? List<int>.from(m['novel_ids']) : null,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'description': description,
    'icon_url': iconUrl,
    'novel_ids': novelIds,
  };
}
