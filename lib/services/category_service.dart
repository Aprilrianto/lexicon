import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart';

class CategoryService {
  final _client = Supabase.instance.client;

  Future<List<Category>> getAll() async {
    final data = await _client.from('categories').select();
    return (data as List<dynamic>)
        .map((e) => Category.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  Future<int> insert(Category cat) async {
    final res = await _client.from('categories').insert(cat.toInsert()).select();
    return (res.first as Map<String, dynamic>)['id'] as int;
  }

  Future<void> update(int id, Map<String, dynamic> fields) async =>
      _client.from('categories').update(fields).eq('id', id);

  Future<void> delete(int id) async =>
      _client.from('categories').delete().eq('id', id);
}
