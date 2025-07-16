import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/chapter.dart';

class ChapterService {
  final _client = Supabase.instance.client;

  /// Baca semua chapter milik satu novel
  Future<List<Chapter>> byNovel(int novelId) async {
    final data = await _client
        .from('chapters')
        .select()
        .eq('novel_id', novelId)
        .order('id'); // urut default ASC

    return (data as List<dynamic>)
        .map((e) => Chapter.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  /// Tambah chapter baru – kembalikan ID
  Future<int> insert(Chapter chapter) async {
    final res =
        await _client.from('chapters').insert(chapter.toInsert()).select();
    return (res.first as Map<String, dynamic>)['id'] as int;
  }

  /// Perbarui sebagian kolom
  Future<void> update(int id, Map<String, dynamic> fields) async =>
      _client.from('chapters').update(fields).eq('id', id);

  /// Hapus chapter
  Future<void> delete(int id) async =>
      _client.from('chapters').delete().eq('id', id);
}
