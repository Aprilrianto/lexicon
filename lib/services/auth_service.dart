// services/auth_service.dart

import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart'; // <-- BARU: Import model Profile

class AuthService {
  final _supabase = Supabase.instance.client;

  // PERUBAHAN: Fungsi login sekarang mengembalikan Future<Profile>
  Future<Profile> login(String email, String password) async {
    try {
      // 1. Lakukan autentikasi seperti biasa
      final authResponse = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      final user = authResponse.user;
      if (user == null) {
        throw const AuthException('Login gagal: User tidak ditemukan.');
      }

      // 2. Ambil data profil dari tabel 'profiles'
      final profileData =
          await _supabase.from('profiles').select().eq('id', user.id).single();

      // 3. Ubah data menjadi objek Profile dan kembalikan
      return Profile.fromMap(profileData);
    } on AuthException {
      // Lempar kembali error dari Supabase agar bisa ditangani UI
      rethrow;
    } catch (e) {
      // Tangani error lain, misal profil tidak ditemukan
      throw Exception('Gagal mengambil data profil: ${e.toString()}');
    }
  }

  Future<AuthResponse> register(String email, String password) {
    return _supabase.auth.signUp(email: email, password: password);
  }

  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  User? get currentUser => _supabase.auth.currentUser;
}
