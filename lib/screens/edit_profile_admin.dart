// screens/edit_profile_admin.dart
import 'dart:io';
import 'package:flutter/foundation.dart'
    show kIsWeb; // Impor untuk cek platform web
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EditProfileAdminScreen extends StatefulWidget {
  const EditProfileAdminScreen({super.key});

  @override
  State<EditProfileAdminScreen> createState() => _EditProfileAdminScreenState();
}

class _EditProfileAdminScreenState extends State<EditProfileAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();

  bool _isLoading = true;
  String? _avatarUrl;
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _fullNameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    try {
      final userId = Supabase.instance.client.auth.currentUser!.id;
      final response =
          await Supabase.instance.client
              .from('profiles')
              .select('username, full_name, bio, avatar_url')
              .eq('id', userId)
              .single();

      if (mounted) {
        setState(() {
          _usernameController.text = response['username'] ?? '';
          _fullNameController.text = response['full_name'] ?? '';
          _bioController.text = response['bio'] ?? '';
          _avatarUrl = response['avatar_url'];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memuat profil: ${e.toString()}')),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final userId = supabase.auth.currentUser!.id;
      String? newAvatarUrl = _avatarUrl;

      // DIPERBAIKI: Logika unggah gambar untuk web dan mobile
      if (_selectedImage != null) {
        final imageBytes = await _selectedImage!.readAsBytes();
        final fileName =
            '${userId}_${DateTime.now().millisecondsSinceEpoch}.${_selectedImage!.name.split('.').last}';
        final filePath = fileName;

        // Menggunakan uploadBinary yang menerima bytes, bukan File
        await supabase.storage
            .from('avatars')
            .uploadBinary(
              filePath,
              imageBytes,
              fileOptions: FileOptions(contentType: _selectedImage!.mimeType),
            );

        newAvatarUrl = supabase.storage.from('avatars').getPublicUrl(filePath);
      }

      await supabase
          .from('profiles')
          .update({
            'username': _usernameController.text.trim(),
            'full_name': _fullNameController.text.trim(),
            'bio': _bioController.text.trim(),
            'avatar_url': newAvatarUrl,
          })
          .eq('id', userId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil berhasil diperbarui!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan profil: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil Admin'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: const Text('Simpan'),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: const EdgeInsets.all(20.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      _buildAvatarPicker(),
                      const SizedBox(height: 30),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Lengkap',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama lengkap tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _usernameController,
                        decoration: const InputDecoration(
                          labelText: 'Nama Pengguna',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Nama pengguna tidak boleh kosong';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _bioController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Bio',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
    );
  }

  Widget _buildAvatarPicker() {
    ImageProvider? backgroundImage;
    if (_selectedImage != null) {
      // DIPERBAIKI: Logika untuk menampilkan gambar yang dipilih
      if (kIsWeb) {
        backgroundImage = NetworkImage(_selectedImage!.path);
      } else {
        backgroundImage = FileImage(File(_selectedImage!.path));
      }
    } else if (_avatarUrl != null && _avatarUrl!.isNotEmpty) {
      backgroundImage = NetworkImage(_avatarUrl!);
    }

    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: backgroundImage,
            child:
                (backgroundImage == null)
                    ? const Icon(Icons.person, size: 60)
                    : null,
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Theme.of(context).primaryColor,
              child: IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: _pickImage,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
