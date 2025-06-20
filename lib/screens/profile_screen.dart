import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart'; // untuk kIsWeb
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/profile.dart';
import '../services/strorage_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final user = Supabase.instance.client.auth.currentUser;
  final _nameController = TextEditingController();
  String? _avatarUrl;
  XFile? _newAvatar;
  bool _loading = true;

  Future<void> _loadProfile() async {
    final res = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user!.id)
        .single();
    final profile = Profile.fromMap(res);
    _nameController.text = profile.fullName;
    _avatarUrl = profile.avatarUrl;
    setState(() => _loading = false);
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _newAvatar = picked);
  }

  Future<void> _save() async {
    String avatarUrl = _avatarUrl ?? '';
    if (_newAvatar != null) {
      final file = kIsWeb ? _newAvatar! : File(_newAvatar!.path);
      avatarUrl = await StorageService.uploadAvatar(user!.id, file);
    }
    await Supabase.instance.client.from('profiles').update({
      'full_name': _nameController.text.trim(),
      'avatar_url': avatarUrl,
    }).eq('id', user!.id);
    Navigator.pop(context);
  }

  Future<void> _deleteAvatar() async {
    await Supabase.instance.client.from('profiles').update({
      'avatar_url': ''
    }).eq('id', user!.id);
    setState(() {
      _avatarUrl = '';
      _newAvatar = null;
    });
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
    if (mounted) Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(onPressed: _logout, icon: const Icon(Icons.logout)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: _pickAvatar,
                    child: CircleAvatar(
                      radius: 50,
                      backgroundImage: _newAvatar != null
                          ? (kIsWeb
                              ? NetworkImage(_newAvatar!.path)
                              : FileImage(File(_newAvatar!.path))) as ImageProvider
                          : (_avatarUrl != null && _avatarUrl!.isNotEmpty)
                              ? NetworkImage(_avatarUrl!)
                              : null,
                      child: (_avatarUrl == null || _avatarUrl!.isEmpty) && _newAvatar == null
                          ? const Icon(Icons.person, size: 40)
                          : null,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: _deleteAvatar,
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove Avatar'),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Full Name'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save),
                    label: const Text('Save Changes'),
                  ),
                ],
              ),
            ),
    );
  }
}
