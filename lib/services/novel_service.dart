import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/novel.dart';

class NovelService {
  final _client = Supabase.instance.client;

  Future<List<Novel>> getAll() async {
    final data = await _client
        .from('novels')
        .select('*, categories(name)')
        .order('id', ascending: false);

    return (data as List<dynamic>)
        .map((e) => Novel.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> insert(Novel novel) async {
    final res = await _client.from('novels').insert(novel.toInsert()).select();
    return (res.first as Map<String, dynamic>)['id'] as int;
  }

  Future<void> update(int id, Map<String, dynamic> fields) async =>
      _client.from('novels').update(fields).eq('id', id);

  Future<void> delete(int id) async =>
      _client.from('novels').delete().eq('id', id);
}
