// screens/explore_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _supabase = Supabase.instance.client;

  final List<String> recentSearches = [
    "TM Academy",
    "J.K Rowling",
    "Mystique",
    "Marmut Merah Jambu",
    "The Lord of The Rings",
    "The Smurf"
  ];

  final List<Map<String, String>> topBooks = [
    {"title": "Critical Eleven", "author": "Ika Natassa"},
    {"title": "Percy Jackson", "author": "Rick Riordan"},
    {"title": "The Mercies", "author": "Kiran Millwood"},
    {"title": "Serendipity", "author": "Erisca Febriani"},
    {"title": "Pergi", "author": "Tere Liye"},
    {"title": "Twice Shy", "author": "Sarah Hogle"},
    {"title": "Harry Potter", "author": "J.K Rowling"},
    {"title": "Twilight", "author": "Stephenie Meyer"},
  ];

  List<Map<String, dynamic>> _categories = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final res = await _supabase.from('categories').select();
    setState(() {
      _categories = List<Map<String, dynamic>>.from(res);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Eksplor'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.deepPurple,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            decoration: InputDecoration(
              hintText: 'Search titles, topics, or authors',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[200],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text('Recent', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Clear All', style: TextStyle(color: Colors.deepPurple)),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: recentSearches.map((text) {
              return Chip(
                label: Text(text),
                onDeleted: () {},
                backgroundColor: Colors.grey[200],
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          const Text('Top Book Search', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: topBooks.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.book),
                title: Text(topBooks[index]['title']!),
                subtitle: Text(topBooks[index]['author']!),
                tileColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              );
            },
          ),
          const SizedBox(height: 20),
          const Text('Top Category Search', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else
            SizedBox(
              height: 80,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (_, i) {
                  final cat = _categories[i];
                  return Column(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.deepPurple.shade100,
                        child: const Icon(Icons.category, color: Colors.deepPurple),
                      ),
                      const SizedBox(height: 4),
                      Text(cat['name'], style: const TextStyle(fontSize: 12)),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
