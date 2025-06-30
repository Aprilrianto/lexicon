import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    // Sembunyikan keyboard
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password konfirmasi tidak cocok.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (!mounted) return;

    try {
      final res = await Supabase.instance.client.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        data: {'username': _usernameController.text.trim()},
      );

      final user = res.user;
      if (user != null && mounted) {
        // Simpan username di tabel 'profiles'
        await Supabase.instance.client.from('profiles').upsert({
          'id': user.id,
          'username': _usernameController.text.trim(),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi gagal.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Terjadi kesalahan: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // DIUBAH: centerTitle diatur ke false agar judul rata kiri
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: const Text(
          'Daftar',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          'Daftar dan Temukan\nDunia Cerita Baru',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Daftar akun untuk menikmati koleksi novel lengkap, simpan progres baca, dan dapatkan rekomendasi khusus.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Username
                        _buildTextFormField(
                          controller: _usernameController,
                          hintText: 'Masukkan Username',
                          prefixIcon: Icons.person_outline,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Username tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Email
                        _buildTextFormField(
                          controller: _emailController,
                          hintText: 'Masukkan Email / Nomor Hp kamu',
                          prefixIcon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Email tidak boleh kosong';
                            }
                            if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) {
                              return 'Masukkan format email yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Password
                        _buildTextFormField(
                          controller: _passwordController,
                          hintText: 'Masukkan Passwordmu',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _isPasswordVisible = !_isPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Password tidak boleh kosong';
                            }
                            if (value.length < 6) {
                              return 'Password minimal 6 karakter';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // Konfirmasi Password
                        _buildTextFormField(
                          controller: _confirmPasswordController,
                          hintText: 'Konfirmasi Passwordmu',
                          prefixIcon: Icons.lock_outline,
                          obscureText: !_isConfirmPasswordVisible,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _isConfirmPasswordVisible
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey[600],
                            ),
                            onPressed: () {
                              setState(() {
                                _isConfirmPasswordVisible =
                                    !_isConfirmPasswordVisible;
                              });
                            },
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Konfirmasi password tidak boleh kosong';
                            }
                            if (value != _passwordController.text) {
                              return 'Password tidak cocok';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        Center(
                          child: Text(
                            'Daftar dengan',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Tombol Google
                        _buildSocialButton(
                          onPressed: () {
                            /* TODO: Implement Google Sign-In */
                          },
                          iconAsset: 'assets/google.png',
                          label: 'Masuk dengan Google',
                        ),
                        const SizedBox(height: 12),
                        // Tombol Facebook
                        _buildSocialButton(
                          onPressed: () {
                            /* TODO: Implement Facebook Sign-In */
                          },
                          iconAsset: 'assets/github.png',
                          label: 'Masuk dengan Github',
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Link ke Halaman Masuk
              Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    children: [
                      const TextSpan(text: 'Sudah memiliki akun? '),
                      TextSpan(
                        text: 'Masuk',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        recognizer:
                            TapGestureRecognizer()
                              ..onTap = () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  '/login',
                                );
                              },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Tombol Daftar
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[300],
                  elevation: 0,
                  minimumSize: const Size(double.infinity, 58),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Daftar',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black54,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget untuk TextFormField
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    String? Function(String?)? validator,
    Widget? suffixIcon,
    bool obscureText = false,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: Colors.grey[600]),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 18),
      ),
    );
  }

  // Helper widget untuk tombol social
  Widget _buildSocialButton({
    required VoidCallback onPressed,
    required String iconAsset,
    required String label,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Image.asset(iconAsset, height: 22),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w600,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.grey[100],
        elevation: 0,
        minimumSize: const Size(double.infinity, 58),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
