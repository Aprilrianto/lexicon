// screens/bookmark_screen.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BookmarkScreen extends StatelessWidget {
  const BookmarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Koleksiku')),
      body: FutureBuilder<List>(
        future: Supabase.instance.client
            .from('bookmarks')
            .select('novels(*)')
            .eq('user_id', user!.id)
            .then((value) => value as List),
        builder: (context, snapshot) {
          if (!snapshot.hasData)
            return const Center(child: CircularProgressIndicator());
          final novels = snapshot.data!;
          return ListView.builder(
            itemCount: novels.length,
            itemBuilder: (context, index) {
              final novel = novels[index]['novels'];
              return ListTile(
                leading: Image.network(
                  novel['cover_url'],
                  width: 50,
                  fit: BoxFit.cover,
                ),
                title: Text(novel['title']),
                subtitle: Text(novel['author']),
              );
            },
          );
        },
      ),
    );
  }
}
