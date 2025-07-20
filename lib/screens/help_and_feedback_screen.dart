import 'package:flutter/material.dart';

class HelpAndFeedbackScreen extends StatelessWidget {
  const HelpAndFeedbackScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text(
          'Bantuan & Umpan Balik',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSectionTitle('Pusat Bantuan (FAQ)'),
          _buildSectionCard([
            _FaqItem(
              question: 'Bagaimana cara menulis cerita baru?',
              answer:
                  'Anda dapat mulai menulis dengan menekan tombol (+) di bagian tengah bawah halaman utama. Isi detail novel Anda, lalu Anda akan diarahkan ke halaman editor untuk menulis isi ceritanya.',
            ),
            const _Divider(),
            _FaqItem(
              question:
                  'Bagaimana cara mengedit novel yang sudah dipublikasikan?',
              answer:
                  'Buka halaman Profil > Karya Saya. Klik pada novel yang ingin Anda edit, lalu pilih "Edit Detail Novel" untuk mengubah sampul/deskripsi, atau "Edit Isi Cerita" untuk mengubah kontennya.',
            ),
            const _Divider(),
            _FaqItem(
              question: 'Apa bedanya Draft dan Publik?',
              answer:
                  'Novel berstatus "Draft" hanya bisa dilihat oleh Anda di halaman "Karya Saya". Novel berstatus "Publik" akan muncul di halaman utama dan bisa dibaca oleh semua pengguna.',
            ),
          ]),
          const SizedBox(height: 24),
          _buildSectionTitle('Kirim Umpan Balik'),
          _buildSectionCard([
            _OptionItem(
              icon: Icons.bug_report_outlined,
              title: 'Laporkan Masalah (Bug)',
              onTap: () {
                /* TODO: Buka email atau form laporan */
              },
            ),
            const _Divider(),
            _OptionItem(
              icon: Icons.lightbulb_outline,
              title: 'Saran & Fitur Baru',
              onTap: () {
                /* TODO: Buka email atau form saran */
              },
            ),
            const _Divider(),
            _OptionItem(
              icon: Icons.email_outlined,
              title: 'Hubungi Kami',
              subtitle: 'Lexiconxorg@gmail.com',
              onTap: () {
                /* TODO: Buka email client */
              },
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0, left: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.black54,
        ),
      ),
    );
  }

  Widget _buildSectionCard(List<Widget> children) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Column(children: children),
    );
  }
}

// Widget khusus untuk item FAQ yang bisa diklik
class _FaqItem extends StatelessWidget {
  final String question;
  final String answer;

  const _FaqItem({required this.question, required this.answer});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        question,
        style: const TextStyle(fontWeight: FontWeight.w500),
      ),
      childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      children: [
        Text(answer, style: TextStyle(color: Colors.grey[700], height: 1.5)),
      ],
    );
  }
}

// Widget khusus untuk item opsi
class _OptionItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _OptionItem({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.black87),
      title: Text(title),
      // DIPERBAIKI: Menambahkan '!' untuk memberitahu Dart bahwa subtitle tidak null di sini
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}
