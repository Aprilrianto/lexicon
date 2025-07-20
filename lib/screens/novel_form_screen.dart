import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/category.dart' as model;
import '../models/novel.dart'; // Impor model Novel
import 'write_story_screen.dart';

class NovelFormScreen extends StatefulWidget {
  // Menerima novel yang sudah ada untuk diedit
  final Novel? existingNovel;
  const NovelFormScreen({super.key, this.existingNovel});

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
  String _status = 'draft';
  List<model.Category> _categories = [];
  String? _existingCoverUrl;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
    // Jika sedang mengedit, isi form dengan data yang ada
    if (widget.existingNovel != null) {
      final novel = widget.existingNovel!;
      _titleController.text = novel.title;
      _authorController.text = novel.author;
      _descriptionController.text = novel.description ?? '';
      _selectedCategoryId = novel.categoryId;
      _status = novel.status ?? 'draft';
      _existingCoverUrl = novel.coverUrl;
    }
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
      /* Handle error */
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

  Future<void> _saveAndProceed() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      _isLoading = true;
    });

    try {
      final supabase = Supabase.instance.client;
      final user = supabase.auth.currentUser;
      if (user == null) throw Exception('Anda harus login.');

      String? coverUrl = _existingCoverUrl;

      // Logika untuk membuat atau mengupdate novel
      if (widget.existingNovel == null) {
        // --- MEMBUAT NOVEL BARU ---
        final response =
            await supabase
                .from('novels')
                .insert({
                  'user_id': user.id,
                  'title': _titleController.text.trim(),
                  'author': _authorController.text.trim(),
                  'description': _descriptionController.text.trim(),
                  'status': _status,
                  'category_id': _selectedCategoryId,
                  'published_date': DateTime.now().toIso8601String(),
                })
                .select()
                .single();

        final newNovelId = response['id'];

        if (_selectedImage != null) {
          coverUrl = await _uploadCover(user.id, newNovelId, _selectedImage!);
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
      } else {
        // --- MENGUPDATE NOVEL YANG ADA ---
        final novelId = widget.existingNovel!.id;
        if (_selectedImage != null) {
          coverUrl = await _uploadCover(user.id, novelId, _selectedImage!);
        }

        await supabase
            .from('novels')
            .update({
              'title': _titleController.text.trim(),
              'author': _authorController.text.trim(),
              'description': _descriptionController.text.trim(),
              'status': _status,
              'category_id': _selectedCategoryId,
              'cover_url': coverUrl,
            })
            .eq('id', novelId);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Detail novel berhasil diperbarui!')),
          );
          Navigator.pop(context, true); // Kembali dan beri sinyal untuk refresh
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan: ${e.toString()}')),
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

  Future<String> _uploadCover(String userId, int novelId, XFile image) async {
    final supabase = Supabase.instance.client;
    final imageBytes = await image.readAsBytes();
    final fileName = '${userId}_${novelId}.${image.name.split('.').last}';
    await supabase.storage
        .from('cover')
        .uploadBinary(
          fileName,
          imageBytes,
          fileOptions: FileOptions(contentType: image.mimeType, upsert: true),
        );
    return supabase.storage.from('cover').getPublicUrl(fileName);
  }

  @override
  Widget build(BuildContext context) {
    // Tentukan teks tombol berdasarkan apakah sedang mengedit atau membuat baru
    final buttonText =
        widget.existingNovel == null ? 'Selanjutnya' : 'Simpan Perubahan';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.existingNovel == null
              ? 'Tambah Cerita Baru'
              : 'Edit Detail Cerita',
          style: const TextStyle(color: Colors.black),
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
      bottomNavigationBar: _buildBottomActionBar(buttonText),
    );
  }

  Widget _buildCoverPicker() {
    ImageProvider? imageProvider;
    if (_selectedImage != null) {
      imageProvider =
          (kIsWeb
                  ? NetworkImage(_selectedImage!.path)
                  : FileImage(File(_selectedImage!.path)))
              as ImageProvider;
    } else if (_existingCoverUrl != null) {
      imageProvider = NetworkImage(_existingCoverUrl!);
    }

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
                  imageProvider != null
                      ? DecorationImage(image: imageProvider, fit: BoxFit.cover)
                      : null,
            ),
            child:
                imageProvider == null
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

  Widget _buildBottomActionBar(String buttonText) {
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
              onPressed: _isLoading ? null : _saveAndProceed,
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
                      : Text(buttonText, style: const TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
