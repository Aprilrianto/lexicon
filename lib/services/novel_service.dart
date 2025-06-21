import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/novel.dart';

class NovelService {
  final _db = Supabase.instance.client.from('novels');

  // Ambil semua novel
  Future<List<Novel>> getAll() async {
    final res = await _db.select().order('created_at', ascending: false);
    return (res as List).map((e) => Novel.fromMap(e)).toList();
  }

  // Ambil novel berdasarkan ID
  Future<Novel?> getById(int id) async {
    final res = await _db.select().eq('id', id).maybeSingle();
    return res != null ? Novel.fromMap(res) : null;
  }

  // Tambah novel baru
  Future<int?> create({
    required String title,
    required String author,
    required String desc,
    required String coverUrl,
    required DateTime publishedDate,
    int? categoryId,
  }) async {
    final res =
        await _db
            .insert({
              'title': title,
              'author': author,
              'description': desc,
              'cover_url': coverUrl,
              'published_date': publishedDate.toIso8601String(),
              'category_id': categoryId,
            })
            .select()
            .maybeSingle();

    return res?['id'];
  }

  // Perbarui data novel
  Future<bool> update(
    int id, {
    required String title,
    required String author,
    required String desc,
    required String coverUrl,
    required DateTime publishedDate,
    int? categoryId,
  }) async {
    try {
      await _db
          .update({
            'title': title,
            'author': author,
            'description': desc,
            'cover_url': coverUrl,
            'published_date': publishedDate.toIso8601String(),
            'category_id': categoryId,
          })
          .eq('id', id);
      return true;
    } catch (e) {
      print("Update error: $e");
      return false;
    }
  }

  // Hapus novel
  Future<bool> delete(int id) async {
    try {
      await _db.delete().eq('id', id);
      return true;
    } catch (e) {
      print("Delete error: $e");
      return false;
    }
  }
}
