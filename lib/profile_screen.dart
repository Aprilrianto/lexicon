import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart'; // Untuk logout

class ProfileScreen extends StatefulWidget {
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Untuk data "Tentang Kamu" yang akan disimpan di user_metadata
  String _aboutMe = "Ketuk disini untuk menambahkan keterangan tentang diri kamu!!";
  final TextEditingController _aboutMeController = TextEditingController();

  // Load data profil dari user_metadata saat inisialisasi
  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  void _loadProfileData() {
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _aboutMe = (currentUser.userMetadata?['about_me'] as String?) ?? "Ketuk disini untuk menambahkan keterangan tentang diri kamu!!";
        _aboutMeController.text = _aboutMe;
      });
    }
  }

  // Fungsi untuk menyimpan perubahan "Tentang Kamu" ke user_metadata
  Future<void> _updateAboutMe() async {
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      setState(() {
        _aboutMe = _aboutMeController.text;
      });
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'about_me': _aboutMeController.text,
            },
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Tentang Kamu berhasil diperbarui!')),
          );
          Navigator.pop(context); // Tutup dialog
        }
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal memperbarui: ${e.message}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan tak terduga: $e')),
          );
        }
      }
    }
  }

  @override
  void dispose() {
    _aboutMeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    // Mengambil username dari user_metadata. Jika tidak ada, gunakan default.
    final String username = (currentUser?.userMetadata?['username'] as String?) ?? 'user123456789';
    final String userHandle = '@${username.toLowerCase().replaceAll(' ', '')}'; // Contoh handle sederhana

    // Dummy data untuk counts karena tidak ada tabel Supabase
    final int daftarBacaanCount = 1;
    final int publikasiCount = 1;
    final int pengikutCount = 2;

    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context); // Kembali ke halaman sebelumnya (HomeScreen)
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Section - Profil Picture, Username, Handle, Counts
            Container(
              color: Colors.grey.shade100, // Background abu-abu seperti desain
              padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.grey.shade300,
                    child: Icon(Icons.person_outline, size: 60, color: Colors.grey.shade500),
                  ),
                  SizedBox(height: 16),
                  Text(
                    username,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    userHandle,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildProfileStat(daftarBacaanCount, 'Daftar Bacaan'),
                      _buildProfileStat(publikasiCount, 'Publikasi'),
                      _buildProfileStat(pengikutCount, 'Pengikut'),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Tentang Kamu
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tentang Kamu',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      _showEditAboutMeDialog(context);
                    },
                    child: Text(
                      _aboutMe,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Cerita oleh [username]
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cerita oleh ${userHandle.substring(1)}', // Menghilangkan '@' dari handle
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Contoh satu cerita (dummy)
                  _buildStoryCard(
                    'Mendaki di gunung larangan',
                    'Tiga pendaki nekat naik Gunung Larangan meski dilarang warga. Satu demi satu hilang secara misterius, hingga hanya satu yang kembali dan menyadari—gunung itu hidup.',
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Daftar Bacaan
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Daftar Bacaan',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    '${userHandle.substring(1)}\'s Reading List (Dummy)',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 16),
                  // Placeholder untuk menambahkan daftar bacaan (dummy)
                  Container(
                    width: 120, // Sesuaikan ukuran
                    height: 180, // Sesuaikan ukuran
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: Center(
                      child: Icon(Icons.add, size: 40, color: Colors.grey.shade500),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 40), // Ruang di bagian bawah
          ],
        ),
      ),
    );
  }

  Widget _buildProfileStat(int count, String label) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }

  Widget _buildStoryCard(String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Placeholder untuk gambar cerita
        Container(
          width: 90,
          height: 120,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.book_outlined, size: 40, color: Colors.grey.shade400),
        ),
        SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEditAboutMeDialog(BuildContext context) {
    _aboutMeController.text = _aboutMe; // Pastikan controller diisi dengan nilai saat ini
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Text('Edit Tentang Kamu'),
          content: TextField(
            controller: _aboutMeController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Tuliskan tentang dirimu...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.pop(dialogContext);
                // Reset controller jika user membatalkan
                _aboutMeController.text = _aboutMe;
              },
            ),
            ElevatedButton(
              child: Text('Simpan'),
              onPressed: () {
                _updateAboutMe(); // Panggil fungsi untuk menyimpan dan menutup dialog
              },
            ),
          ],
        );
      },
    );
  }
}