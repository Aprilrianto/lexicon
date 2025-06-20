import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class StorageService {
  /// Upload Avatar ke bucket 'avatars'
  static Future<String> uploadAvatar(String userId, dynamic file) async {
    final path = 'avatars/$userId.jpg';

    try {
      Uint8List bytes;

      if (kIsWeb) {
        // Web: file adalah XFile
        bytes = await (file as XFile).readAsBytes();
      } else {
        // Mobile: file adalah File
        bytes = await (file as File).readAsBytes();
      }

      await Supabase.instance.client.storage
          .from('avatars')
          .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));

      final url = Supabase.instance.client.storage.from('avatars').getPublicUrl(path);
      return url;
    } catch (e) {
      print('Upload avatar error: $e');
      return '';
    }
  }

  /// Upload Cover ke bucket 'cover'
  static Future<String> uploadCover(int novelId, dynamic file) async {
    final path = 'cover/$novelId.jpg';

    try {
      Uint8List bytes;

      if (kIsWeb) {
        bytes = await (file as XFile).readAsBytes();
      } else {
        bytes = await (file as File).readAsBytes();
      }

      await Supabase.instance.client.storage
          .from('cover')
          .uploadBinary(path, bytes, fileOptions: const FileOptions(upsert: true));

      final url = Supabase.instance.client.storage.from('cover').getPublicUrl(path);
      return url;
    } catch (e) {
      print('Upload cover error: $e');
      return '';
    }
  }
}
