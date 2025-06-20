import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/strorage_service.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  String? _avatarUrl;
  XFile? _pickedFile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final res = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user!.id)
        .single();

    _nameController.text = res['full_name'] ?? '';
    _usernameController.text = res['username'] ?? '';
    _bioController.text = res['bio'] ?? '';
    _avatarUrl = res['avatar_url'];
    setState(() => _loading = false);
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _pickedFile = picked);
  }

  Future<void> _deleteAvatar() async {
    await Supabase.instance.client
        .from('profiles')
        .update({'avatar_url': ''})
        .eq('id', user!.id);
    setState(() {
      _avatarUrl = '';
      _pickedFile = null;
    });
  }

  Future<void> _saveProfile() async {
    String avatarUrl = _avatarUrl ?? '';
    if (_pickedFile != null) {
      final file = kIsWeb ? _pickedFile! : File(_pickedFile!.path);
      avatarUrl = await StorageService.uploadAvatar(user!.id, file);
    }

    await Supabase.instance.client.from('profiles').update({
      'full_name': _nameController.text.trim(),
      'username': _usernameController.text.trim(),
      'bio': _bioController.text.trim(),
      'avatar_url': avatarUrl,
    }).eq('id', user!.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profil berhasil diperbarui')),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.grey.shade300,
                        backgroundImage: _pickedFile != null
                            ? FileImage(File(_pickedFile!.path))
                            : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                                ? NetworkImage(_avatarUrl!) as ImageProvider
                                : null,
                        child: (_avatarUrl == null || _avatarUrl!.isEmpty) &&
                                _pickedFile == null
                            ? const Icon(Icons.person, size: 50, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        right: 0,
                        bottom: 0,
                        child: Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, size: 20),
                              onPressed: _pickImage,
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, size: 20),
                              onPressed: _deleteAvatar,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Nama Lengkap'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _usernameController,
                  decoration: const InputDecoration(labelText: 'Username'),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _bioController,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Tentang Kamu',
                    hintText: 'Tambahkan keterangan singkat tentang diri kamu',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _saveProfile,
                  icon: const Icon(Icons.save),
                  label: const Text("Simpan Perubahan"),
                ),
              ],
            ),
    );
  }
}
