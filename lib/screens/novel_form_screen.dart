import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';            // kIsWeb
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/novel.dart';
import '../models/category.dart' as model;            // ← alias untuk model Category
import '../services/novel_service.dart';
import '../services/category_service.dart';
import '../services/strorage_service.dart';

class NovelFormScreen extends StatefulWidget {
  final Novel? existing;
  const NovelFormScreen({super.key, this.existing});

  @override
  State<NovelFormScreen> createState() => _NovelFormScreenState();
}

class _NovelFormScreenState extends State<NovelFormScreen> {
  final _formKey  = GlobalKey<FormState>();
  final _novelSvc = NovelService();
  final _catSvc   = CategoryService();

  late TextEditingController _title;
  late TextEditingController _author;
  late TextEditingController _desc;

  String _status = 'draft';
  int?   _catId;

  // ---- Gambar ----
  File?     _coverFile;        // mobile/desktop
  XFile?    _webPickedFile;    // web upload
  Uint8List? _webBytes;        // web preview

  List<model.Category> _cats = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _title  = TextEditingController(text: widget.existing?.title ?? '');
    _author = TextEditingController(text: widget.existing?.author ?? '');
    _desc   = TextEditingController(text: widget.existing?.description ?? '');
    _status = widget.existing?.status ?? 'draft';
    _catId  = widget.existing?.categoryId;
    _loadCats();
  }

  Future<void> _loadCats() async {
    final list = await _catSvc.getAll();
    if (mounted) setState(() => _cats = list);
  }

  // ---------- PILIH GAMBAR ----------
  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked == null) return;

    if (kIsWeb) {
      _webPickedFile = picked;
      _webBytes      = await picked.readAsBytes();
    } else {
      _coverFile     = File(picked.path);
    }
    if (mounted) setState(() {});
  }

  // ---------- SIMPAN ----------
  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _catId == null) return;
    setState(() => _saving = true);

    try {
      // objek dasar tanpa cover
      final baseNovel = Novel(
        id           : widget.existing?.id ?? 0,
        title        : _title.text,
        author       : _author.text,
        description  : _desc.text,
        categoryId   : _catId!,
        status       : _status,
        chapterCount : widget.existing?.chapterCount ?? 0,
        coverUrl     : null,
        publishedDate: DateTime.now(),
      );

      // ---------- INSERT ----------
      if (widget.existing == null) {
        final newId = await _novelSvc.insert(baseNovel);

        if (kIsWeb && _webPickedFile != null) {
          final url = await StorageService.uploadCover(newId, _webPickedFile!);
          await _novelSvc.update(newId, {'cover_url': url});
        } else if (!kIsWeb && _coverFile != null) {
          final url = await StorageService.uploadCover(newId, _coverFile!);
          await _novelSvc.update(newId, {'cover_url': url});
        }
      }
      // ---------- UPDATE ----------
      else {
        final id = widget.existing!.id;
        String? coverUrl = widget.existing!.coverUrl;

        if (kIsWeb && _webPickedFile != null) {
          coverUrl = await StorageService.uploadCover(id, _webPickedFile!);
        } else if (!kIsWeb && _coverFile != null) {
          coverUrl = await StorageService.uploadCover(id, _coverFile!);
        }

        await _novelSvc.update(id, {
          ...baseNovel.toInsert(),
          'cover_url': coverUrl,
        });
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existing == null ? 'Tambah Novel' : 'Edit Novel'),
      ),
      body: _saving
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  GestureDetector(
                    onTap: _pickImage,
                    child: _buildCoverPreview(),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _title,
                    decoration: const InputDecoration(labelText: 'Judul'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Judul wajib' : null,
                  ),
                  TextFormField(
                    controller: _author,
                    decoration: const InputDecoration(labelText: 'Penulis'),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Penulis wajib' : null,
                  ),
                  DropdownButtonFormField<int>(
                    value: _catId,
                    decoration: const InputDecoration(labelText: 'Kategori'),
                    items: _cats.map<DropdownMenuItem<int>>(
                      (model.Category c) => DropdownMenuItem(
                        value: c.id,
                        child: Text(c.name),
                      ),
                    ).toList(),
                    onChanged: (v) => _catId = v,
                    validator: (v) => v == null ? 'Pilih kategori' : null,
                  ),
                  TextFormField(
                    controller: _desc,
                    decoration: const InputDecoration(labelText: 'Sinopsis'),
                    minLines: 2,
                    maxLines: 5,
                  ),
                  DropdownButtonFormField<String>(
                    value: _status,
                    decoration: const InputDecoration(labelText: 'Status'),
                    items: const [
                      DropdownMenuItem(value: 'draft', child: Text('Draft')),
                      DropdownMenuItem(
                          value: 'published', child: Text('Published')),
                    ],
                    onChanged: (v) => _status = v ?? 'draft',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Simpan'),
                  ),
                ],
              ),
            ),
    );
  }

  // ---------- PREVIEW COVER ----------
  Widget _buildCoverPreview() {
    if (kIsWeb && _webBytes != null) {
      return Image.memory(_webBytes!, height: 180, fit: BoxFit.cover);
    } else if (!kIsWeb && _coverFile != null) {
      return Image.file(_coverFile!, height: 180, fit: BoxFit.cover);
    } else if (widget.existing?.coverUrl != null) {
      return Image.network(widget.existing!.coverUrl!,
          height: 180, fit: BoxFit.cover);
    } else {
      return Container(
        height: 180,
        color: Colors.grey.shade200,
        child: const Icon(Icons.camera_alt),
      );
    }
  }
}
