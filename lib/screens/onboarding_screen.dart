import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, String>> onboardingData = [
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
          'Temukan cerita yang sesuai dengan seleramu! Dari kisah romantis, petualangan fantasi epik, hingga misteri yang menegangkan semua genre favorit ada di sini. ',
    },
    {
      'image': 'assets/dua_orang.png',
      'text': 'Simpan bacaan favoritmu dengan satu klik',
      'subtitle':
          'Simpan semua bacaan favoritmu dengan mudah dalam satu koleksi pribadi. Klik sekali untuk menyimpan, akses kapan pun kamu mau tanpa repot mencari lagi!',
    },
  ];

  void _nextPage() {
    if (_currentPage < onboardingData.length - 1) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    }
  }

  void _skip() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: onboardingData.length,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (context, index) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 80),
                  Image.asset(onboardingData[index]['image']!, height: 400),
                  SizedBox(height: 40),
                  // penanda halaman onboarding
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      onboardingData.length,
                      (dotIndex) => AnimatedContainer(
                        duration: Duration(milliseconds: 200),
                        margin: EdgeInsets.symmetric(horizontal: 4),
                        width: 24,
                        height: 8,
                        decoration: BoxDecoration(
                          color:
                              _currentPage == dotIndex
                                  ? Color(0xFF1E1E1E)
                                  : Color(0xFFD9D9D9),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24),
                  // untuk teks dan subteks onboarding
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      children: [
                        Text(
                          onboardingData[index]['text']!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 16),
                        Text(
                          onboardingData[index]['subtitle'] ?? '',
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF8D8D8D),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          // button lewati di kanan atas
          Positioned(
            top: 40,
            right: 20,
            child: GestureDetector(
              onTap: _skip,
              child: Row(
                children: [
                  Text(
                    'Lewati',
                    style: TextStyle(fontSize: 12, color: Color(0xFF1E1E1E)),
                  ),
                  SizedBox(width: 4),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Color(0xFF1E1E1E),
                  ),
                ],
              ),
            ),
          ),
          // Tombol Selanjutnya/Mulai
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 48),
                backgroundColor: Color(0xFF1E1E1E),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                _currentPage == onboardingData.length - 1
                    ? 'Mulai'
                    : 'Selanjutnya',
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
