import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Data untuk setiap halaman onboarding
  final List<Map<String, String>> _onboardingData = [
    {
      'image': 'assets/orang_duduk.png',
      'text': 'Semua Novel Favorit dalam Genggaman',
      'subtitle':
          'Nikmati pengalaman membaca yang menyenangkan dengan akses ke ribuan novel pilihan. Baca kapan pun kamu dan dimanapun kamu mau',
    },
    {
      'image': 'assets/orang_menunjuk.png',
      'text': "Temukan dunia baru dalam setiap genre",
      'subtitle':
          'Temukan cerita yang sesuai dengan seleramu! Dari kisah romantis, petualangan fantasi epik, hingga misteri yang menegangkan semua genre favorit ada di sini.',
    },
    {
      'image': 'assets/dua_orang.png',
      'text': 'Simpan bacaan favoritmu dengan satu klik',
      'subtitle':
          'Simpan semua bacaan favoritmu dengan mudah dalam satu koleksi pribadi. Klik sekali untuk menyimpan, akses kapan pun kamu mau tanpa repot mencari lagi!',
    },
  ];

  // Fungsi yang dipanggil saat onboarding selesai (baik di-skip atau selesai)
  Future<void> _finishOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    // Set flag bahwa onboarding sudah dilihat
    await prefs.setBool('onboarding_seen', true);
    if (mounted) {
      // Gunakan named route untuk navigasi yang konsisten
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  // Fungsi untuk pindah ke halaman selanjutnya atau menyelesaikan onboarding
  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      _finishOnboarding();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Konten utama yang bisa di-swipe
            _buildPageView(),
            // Tombol "Lewati" di kanan atas
            _buildSkipButton(),
            // Indikator halaman dan tombol aksi di bagian bawah
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  // Widget untuk PageView
  Widget _buildPageView() {
    return PageView.builder(
      controller: _pageController,
      itemCount: _onboardingData.length,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemBuilder: (context, index) {
        return _buildOnboardingPage(
          imagePath: _onboardingData[index]['image']!,
          title: _onboardingData[index]['text']!,
          subtitle: _onboardingData[index]['subtitle']!,
        );
      },
    );
  }

  // DIPERBAIKI: Widget untuk membangun satu halaman onboarding dengan layout yang fleksibel
  Widget _buildOnboardingPage({
    required String imagePath,
    required String title,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        children: [
          const Spacer(flex: 2), // Memberi ruang fleksibel di atas
          Image.asset(
            imagePath,
            height: 320, // Ukuran gambar sedikit dikurangi
            fit: BoxFit.contain,
          ),
          const SizedBox(height: 50),
          Text(
            title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 14, color: Color(0xFF8D8D8D)),
            textAlign: TextAlign.center,
          ),
          const Spacer(
            flex: 3,
          ), // Memberi ruang fleksibel di bawah untuk tombol
        ],
      ),
    );
  }

  // Widget untuk tombol "Lewati"
  Widget _buildSkipButton() {
    return Positioned(
      top: 16,
      right: 20,
      child: TextButton(
        onPressed: _finishOnboarding,
        child: const Row(
          children: [
            Text(
              'Lewati',
              style: TextStyle(fontSize: 14, color: Color(0xFF1E1E1E)),
            ),
            SizedBox(width: 4),
            Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF1E1E1E)),
          ],
        ),
      ),
    );
  }

  // Widget untuk kontrol di bagian bawah (indikator dan tombol)
  Widget _buildBottomControls() {
    return Positioned(
      bottom: 40,
      left: 20,
      right: 20,
      child: Column(
        children: [
          // Indikator halaman
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              _onboardingData.length,
              (dotIndex) => AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 24,
                height: 8,
                decoration: BoxDecoration(
                  color:
                      _currentPage == dotIndex
                          ? const Color(0xFF1E1E1E)
                          : const Color(0xFFD9D9D9),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          // Tombol Aksi
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              backgroundColor: const Color(0xFF1E1E1E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text(
              _currentPage == _onboardingData.length - 1
                  ? 'Mulai'
                  : 'Selanjutnya',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
