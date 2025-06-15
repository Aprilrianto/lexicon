import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'login_page.dart'; // Import LoginPage untuk navigasi kembali
import 'profile_screen.dart'; // Import ProfileScreen

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0; // Untuk Bottom Navigation Bar

  // Data dummy untuk kategori
  final List<String> _categories = [
    'Fantasi', 'Romantis', 'Misteri', 'Fiksi Ilmiah', 'Petualangan', 'Horor', 'Komedi'
  ];

  // Data dummy untuk novel (bisa disesuaikan dengan data nyata)
  final List<Map<String, String>> _trendingNovels = [
    {'title': 'Gadis Mungil', 'author': 'By Mofia'},
    {'title': 'Dosenku Suka...', 'author': 'By Mofia'},
    {'title': 'Gairah', 'author': 'By Mofia'},
    {'title': 'Sang Pembunuh', 'author': 'By Mofia'},
  ];

  final List<Map<String, String>> _recommendedNovels = [
    {'title': 'Petualangan Aneh', 'author': 'By Jhon Doe'},
    {'title': 'Cinta Tak Berujung', 'author': 'By Jane Smith'},
    {'title': 'Misteri Rumah Tua', 'author': 'By Mark Lee'},
    {'title': 'Masa Depan Kita', 'author': 'By Chris White'},
  ];

  @override
  void initState() {
    super.initState();
    // Panggil modal untuk profil membaca setelah frame pertama selesai dirender
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Kita hanya akan memunculkan ini sekali. Anda bisa menggunakan
      // SharedPreferences untuk melacak apakah user sudah mengisi ini atau belum.
      // Untuk demo ini, akan muncul setiap kali HomeScreen dimuat.
      _showReadingProfileModal();
    });
  }

  // Fungsi untuk menampilkan modal "Profil Membaca Anda"
  void _showReadingProfileModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Agar modal bisa menyesuaikan keyboard jika ada input
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return ReadingProfileSheet();
      },
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    // Navigasi Bottom Navigation Bar
    switch (index) {
      case 0:
      // Beranda (sudah di sini)
        break;
      case 1:
      // Eksplor - bisa navigasi ke ExploreScreen()
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Halaman Eksplor')),
        );
        break;
      case 2:
      // Koleksi - bisa navigasi ke CollectionScreen()
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Halaman Koleksi')),
        );
        break;
      case 3:
      // Notifikasi - bisa navigasi ke NotificationsScreen()
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Halaman Notifikasi')),
        );
        break;
      case 4:
      // Profil
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ProfileScreen()),
        ).then((_) {
          // Ketika kembali dari ProfileScreen, kembalikan selectedIndex ke 0 (Beranda)
          if (mounted) {
            setState(() {
              _selectedIndex = 0;
            });
          }
        });
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lexicon'),
        centerTitle: true,
        leading: Icon(Icons.menu), // Ikon menu di kiri
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () async {
              await Supabase.instance.client.auth.signOut();
              // Pastikan untuk mengarahkan ke LoginPage setelah logout
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginPage()),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            TextField(
              decoration: InputDecoration(
                hintText: 'Cari judul, penulis, atau genre',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: EdgeInsets.symmetric(vertical: 0),
              ),
            ),
            SizedBox(height: 24),

            // Categories
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: Chip(
                      label: Text(_categories[index]),
                      backgroundColor: Colors.grey.shade200,
                      labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 24),

            // Trending Minggu Ini
            _buildSectionHeader('Trending Minggu Ini', 'Tampilkan Semua >'),
            SizedBox(height: 16),
            SizedBox(
              height: 200, // Tinggi yang cukup untuk Card novel
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _trendingNovels.length,
                itemBuilder: (context, index) {
                  return _buildNovelCard(
                    _trendingNovels[index]['title']!,
                    _trendingNovels[index]['author']!,
                  );
                },
              ),
            ),
            SizedBox(height: 24),

            // Yang mungkin kamu suka
            _buildSectionHeader('Yang mungkin kamu suka', 'Tampilkan Semua >'),
            SizedBox(height: 16),
            SizedBox(
              height: 200, // Tinggi yang cukup untuk Card novel
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _recommendedNovels.length,
                itemBuilder: (context, index) {
                  return _buildNovelCard(
                    _recommendedNovels[index]['title']!,
                    _recommendedNovels[index]['author']!,
                  );
                },
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: 'Beranda',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.explore_outlined),
            label: 'Eksplor',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.collections_bookmark_outlined),
            label: 'Koleksi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications_outlined),
            label: 'Notifikasi',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profil',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.indigo,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true, // Tampilkan label untuk yang tidak dipilih
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed, // Agar item tidak bergerak saat dipilih
      ),
    );
  }

  Widget _buildSectionHeader(String title, String actionText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        TextButton(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('$title: ${actionText} diklik!')),
            );
          },
          child: Text(
            actionText,
            style: TextStyle(color: Colors.indigo, fontSize: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildNovelCard(String title, String author) {
    return Container(
      width: 140, // Lebar card
      margin: EdgeInsets.only(right: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder untuk gambar novel
          Container(
            height: 140, // Tinggi gambar
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.image, size: 50, color: Colors.grey.shade400),
          ),
          SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            author,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// Widget untuk Bottom Sheet "Profil Membaca Anda"
class ReadingProfileSheet extends StatefulWidget {
  @override
  _ReadingProfileSheetState createState() => _ReadingProfileSheetState();
}

class _ReadingProfileSheetState extends State<ReadingProfileSheet> {
  String? _selectedAgeRange;
  List<String> _selectedGenres = [];

  final List<String> _ageRanges = ['<13', '13-17', '18-24', '25-29', '30-39', '40+'];
  final List<String> _allGenres = [
    'Romantis', 'Fantasi', 'Drama', 'Horor', 'Misteri', 'Fiksi Ilmiah',
    'Petualangan', 'Thriller', 'Sejarah', 'Biografi', 'Komedi', 'Aksi'
  ];

  // Simpan preferensi di user_metadata Supabase
  Future<void> _saveReadingPreferences() async {
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null) {
      try {
        await Supabase.instance.client.auth.updateUser(
          UserAttributes(
            data: {
              'age_range': _selectedAgeRange,
              'preferred_genres': _selectedGenres,
            },
          ),
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Preferensi membaca disimpan!')),
          );
          Navigator.pop(context); // Tutup modal
        }
      } on AuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan preferensi: ${e.message}')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Terjadi kesalahan saat menyimpan: $e')),
          );
        }
      }
    }
  }

  // Load preferensi dari user_metadata saat inisialisasi
  @override
  void initState() {
    super.initState();
    final User? currentUser = Supabase.instance.client.auth.currentUser;
    if (currentUser != null && currentUser.userMetadata != null) {
      setState(() {
        _selectedAgeRange = currentUser.userMetadata!['age_range'] as String?;
        if (currentUser.userMetadata!['preferred_genres'] is List) {
          _selectedGenres = List<String>.from(currentUser.userMetadata!['preferred_genres'] as List);
        }
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        24,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              icon: Icon(Icons.close),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Text(
            'Profil Membaca Anda',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Bantu kami merekomendasikan cerita yang paling sesuai dengan selera Anda (usia dan genre novel favoritmu) di bawah ini.',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(height: 24),

          // Pilihan Rentang Usia
          Text(
            'Rentang Usia',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _ageRanges.map((age) {
              final isSelected = _selectedAgeRange == age;
              return ChoiceChip(
                label: Text(age),
                selected: isSelected,
                selectedColor: Colors.indigo.shade100,
                checkmarkColor: Colors.indigo,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.indigo.shade800 : Colors.grey.shade700,
                ),
                onSelected: (selected) {
                  setState(() {
                    _selectedAgeRange = selected ? age : null;
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 24),

          // Pilihan Genre Favorit
          Text(
            'Genre Favorit',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Wrap(
            spacing: 8.0,
            runSpacing: 8.0,
            children: _allGenres.map((genre) {
              final isSelected = _selectedGenres.contains(genre);
              return ChoiceChip(
                label: Text(genre),
                selected: isSelected,
                selectedColor: Colors.indigo.shade100,
                checkmarkColor: Colors.indigo,
                backgroundColor: Colors.grey.shade200,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.indigo.shade800 : Colors.grey.shade700,
                ),
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedGenres.add(genre);
                    } else {
                      _selectedGenres.remove(genre);
                    }
                  });
                },
              );
            }).toList(),
          ),
          SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _saveReadingPreferences,
              child: Text('Simpan'),
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
              ),
            ),
          ),
        ],
      ),
    );
  }
}