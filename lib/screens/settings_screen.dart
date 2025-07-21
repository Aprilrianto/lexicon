import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isNotificationOn = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Latar belakang disamakan
      appBar: AppBar(
        title: const Text(
          'Pengaturan',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.grey[200],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        centerTitle: false, // Judul rata kiri agar konsisten
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0), // Padding untuk seluruh list
        children: [
          _buildSectionCard(
            children: [
              _buildSettingItem(
                title: 'Bahasa',
                value: 'Bahasa Indonesia',
                onTap: () {},
              ),
              const _Divider(),
              _buildSettingItem(title: 'Usia', value: '19-24', onTap: () {}),
            ],
          ),
          const SizedBox(height: 20),
          _buildSectionCard(
            children: [
              SwitchListTile(
                title: const Text('Notifikasi'),
                value: _isNotificationOn,
                onChanged: (bool value) {
                  setState(() {
                    _isNotificationOn = value;
                  });
                },
                activeColor: Colors.black,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
              ),
              const _Divider(),
              _buildSettingItem(title: 'Akun Saya', onTap: () {}),
              const _Divider(),
              _buildSettingItem(title: 'Periksa Pembaruan', onTap: () {}),
              const _Divider(),
              _buildSettingItem(title: 'Tentang', onTap: () {}),
              const _Divider(),
              _buildSettingItem(
                title: 'Mode Gelap',
                onTap: () {},
                trailingIcon: Icons.keyboard_arrow_down,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper widget untuk membuat Card pembungkus
  Widget _buildSectionCard({required List<Widget> children}) {
    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Column(children: children),
    );
  }

  // Helper widget untuk membuat item pengaturan
  Widget _buildSettingItem({
    required String title,
    String? value,
    required VoidCallback onTap,
    IconData trailingIcon = Icons.arrow_forward_ios,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 4.0,
      ),
      title: Text(title),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null)
            Text(
              value,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          const SizedBox(width: 8),
          Icon(trailingIcon, size: 16, color: Colors.grey),
        ],
      ),
      onTap: onTap,
    );
  }
}

// Helper widget untuk Divider agar lebih rapi
class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, indent: 16, endIndent: 16);
  }
}
