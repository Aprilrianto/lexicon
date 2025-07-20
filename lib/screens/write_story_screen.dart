import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WriteStoryScreen extends StatefulWidget {
  final int novelId;
  const WriteStoryScreen({super.key, required this.novelId});

  @override
  State<WriteStoryScreen> createState() => _WriteStoryScreenState();
}

class _WriteStoryScreenState extends State<WriteStoryScreen> {
  final _contentController = TextEditingController();
  bool _isSaving = false;

  Future<void> _saveContent() async {
    setState(() {
      _isSaving = true;
    });
    final content = _contentController.text.trim();
    if (content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi cerita tidak boleh kosong.')),
      );
      setState(() {
        _isSaving = false;
      });
      return;
    }

    try {
      await Supabase.instance.client
          .from('novels')
          .update({'isi': content})
          .eq('id', widget.novelId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cerita berhasil disimpan!')),
        );
        // DIUBAH: Menggunakan pushNamedAndRemoveUntil untuk navigasi yang bersih ke home
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal menyimpan cerita: ${e.toString()}')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tulis Cerita'),
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _saveContent,
            child:
                _isSaving ? const Text('Menyimpan...') : const Text('Simpan'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextField(
          controller: _contentController,
          maxLines: null, // Memungkinkan input teks tidak terbatas
          expands: true, // Mengisi seluruh ruang yang tersedia
          keyboardType: TextInputType.multiline,
          decoration: const InputDecoration(
            hintText: 'Mulai tulis ceritamu di sini...',
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }
}
