import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart' as model; // Alias agar tidak bentrok
import 'write_story_screen.dart'; // Impor halaman tulis cerita

class NovelFormScreen extends StatefulWidget {
  const NovelFormScreen({super.key});

  @override
  State<NovelFormScreen> createState() => _NovelFormScreenState();
}

class _NovelFormScreenState extends State<NovelFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();

  bool _isLoading = false;
  XFile? _selectedImage;
  int? _selectedCategoryId;
  String _status = 'draft'; // Default status
  List<model.Category> _categories = [];

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _fetchCategories() async {
    try {
      final response =
          await Supabase.instance.client.from('categories').select();
      if (mounted) {
        setState(() {
          _categories =
              (response as List).map((e) => model.Category.fromMap(e)).toList();
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 50,
    );
    if (picked != null) {
      setState(() {
        _selectedImage = picked;
      });
    }
  }

  Future<void> _goToNextStep() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null)
        throw Exception('Anda harus login untuk membuat cerita.');

      // DIUBAH: Menambahkan 'published_date' saat membuat novel baru
      final response =
          await supabase
              .from('novels')
              .insert({
                'title': _titleController.text.trim(),
                'author': _authorController.text.trim(),
                'description': _descriptionController.text.trim(),
                'status': _status,
                'category_id': _selectedCategoryId,
                'published_date':
                    DateTime.now()
                        .toIso8601String(), // Tanggal otomatis ditambahkan
              })
              .select()
              .single();

      final newNovelId = response['id'];
      String? coverUrl;

      if (_selectedImage != null) {
        final imageBytes = await _selectedImage!.readAsBytes();
        final fileName =
            '${user.id}_${newNovelId}.${_selectedImage!.name.split('.').last}';
        await supabase.storage
            .from('cover')
            .uploadBinary(
              fileName,
              imageBytes,
              fileOptions: FileOptions(
                contentType: _selectedImage!.mimeType,
                upsert: true,
              ),
            );
        coverUrl = supabase.storage.from('cover').getPublicUrl(fileName);

        await supabase
            .from('novels')
            .update({'cover_url': coverUrl})
            .eq('id', newNovelId);
      }

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WriteStoryScreen(novelId: newNovelId),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat cerita: ${e.toString()}')),
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Tambah Cerita Baru',
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20.0),
          children: [
            _buildCoverPicker(),
            const SizedBox(height: 24),
            _buildTextField(controller: _titleController, label: 'Judul Novel'),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _authorController,
              label: 'Nama Penulis',
            ),
            const SizedBox(height: 16),
            _buildCategoryDropdown(),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _descriptionController,
              label: 'Deskripsi Cerita (Sinopsis)',
              maxLines: 5,
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomActionBar(),
    );
  }

  Widget _buildCoverPicker() {
    return Row(
      children: [
        InkWell(
          onTap: _pickImage,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            width: 100,
            height: 140,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
              image:
                  _selectedImage != null
                      ? DecorationImage(
                        image:
                            (kIsWeb
                                    ? NetworkImage(_selectedImage!.path)
                                    : FileImage(File(_selectedImage!.path)))
                                as ImageProvider,
                        fit: BoxFit.cover,
                      )
                      : null,
            ),
            child:
                _selectedImage == null
                    ? const Center(child: Icon(Icons.add, color: Colors.grey))
                    : null,
          ),
        ),
        const SizedBox(width: 16),
        const Expanded(
          child: Text(
            'Tambahkan Sampul',
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      validator:
          (value) =>
              value == null || value.isEmpty
                  ? '$label tidak boleh kosong'
                  : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<int>(
      value: _selectedCategoryId,
      decoration: InputDecoration(
        labelText: 'Pilih Kategori',
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      items:
          _categories.map((category) {
            return DropdownMenuItem<int>(
              value: category.id,
              child: Text(category.name),
            );
          }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedCategoryId = value;
        });
      },
      validator: (value) => value == null ? 'Pilih kategori' : null,
    );
  }

  Widget _buildBottomActionBar() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          ToggleButtons(
            isSelected: [_status == 'draft', _status == 'published'],
            onPressed: (index) {
              setState(() {
                _status = index == 0 ? 'draft' : 'published';
              });
            },
            borderRadius: BorderRadius.circular(12),
            selectedColor: Colors.white,
            fillColor: Colors.black,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Draft'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text('Publik'),
              ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _goToNextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 3,
                      )
                      : const Text(
                        'Selanjutnya',
                        style: TextStyle(fontSize: 16),
                      ),
            ),
          ),
        ],
      ),
    );
  }
}
