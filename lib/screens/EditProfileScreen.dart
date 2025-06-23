import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/strorage_service.dart'; // pastikan path sesuai

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  final _formKey = GlobalKey<FormState>();
  bool _loading = true;
  bool _saving = false;

  String? _fullName;
  String? _username;
  String? _bio;
  String? _avatarUrl;
  dynamic _newImage; // bisa File atau XFile

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final data = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user!.id)
        .single();

    setState(() {
      _fullName = data['full_name'];
      _username = data['username'];
      _bio = data['bio'];
      _avatarUrl = data['avatar_url'];
      _loading = false;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _newImage = picked;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);
    _formKey.currentState!.save();

    String avatarUrl = _avatarUrl ?? '';

    if (_newImage != null) {
      avatarUrl = await StorageService.uploadAvatar(user!.id, _newImage);
    }

    await Supabase.instance.client.from('profiles').update({
      'full_name': _fullName,
      'username': _username,
      'bio': _bio,
      'avatar_url': avatarUrl,
    }).eq('id', user!.id);

    setState(() => _saving = false);

    if (mounted) {
      Navigator.pop(context); // kembali ke halaman profil
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profil")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickImage,
                  child: CircleAvatar(
                    radius: 50,
                    backgroundImage: _newImage != null
                        ? (kIsWeb
                            ? Image.network(_newImage.path).image
                            : FileImage(File(_newImage.path)) as ImageProvider)
                        : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                            ? NetworkImage('$_avatarUrl?v=${DateTime.now().millisecondsSinceEpoch}')
                            : null,
                    child: (_newImage == null && (_avatarUrl == null || _avatarUrl!.isEmpty))
                        ? const Icon(Icons.person, size: 50)
                        : null,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _fullName,
                decoration: const InputDecoration(labelText: "Nama Lengkap"),
                onSaved: (val) => _fullName = val,
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _username,
                decoration: const InputDecoration(labelText: "Username"),
                onSaved: (val) => _username = val,
                validator: (val) => val == null || val.isEmpty ? 'Wajib diisi' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                initialValue: _bio,
                maxLines: 4,
                decoration: const InputDecoration(labelText: "Bio"),
                onSaved: (val) => _bio = val,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _saving ? null : _saveProfile,
                icon: const Icon(Icons.save),
                label: Text(_saving ? "Menyimpan..." : "Simpan"),
              )
            ],
          ),
        ),
      ),
    );
  }
}
