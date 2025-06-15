import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _pages = [
    {
      'title': 'Semua Novel Favorit dalam Genggaman',
      'desc': 'Nikmati pengalaman membaca yang menyenangkan dengan akses ke ribuan novel pilihan. Baca kapan pun kamu dan di manapun kamu mau.',
    },
    {
      'title': 'Temukan dunia baru dalam setiap genre',
      'desc': 'Temukan cerita yang sesuai dengan seleramu! Dari kisah romantis, petualangan fantasi, hingga misteri yang menegangkan semua genre favorit ada di sini.',
    },
    {
      'title': 'Simpan bacaan favoritmu dengan satu klik',
      'desc': 'Simpan semua bacaan favoritmu dengan mudah dalam satu koleksi pribadi. Klik sekali untuk menyimpan, akses kapan pun kamu mau tanpa repot mencari lagi!',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView.builder(
        controller: _controller,
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _currentIndex = index),
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 48),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(),
                Icon(Icons.image, size: 160, color: Colors.grey.shade300),
                Text(
                  _pages[index]['title']!,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.indigo[900],
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 16),
                Text(
                  _pages[index]['desc']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                _buildIndicator(),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_currentIndex < _pages.length - 1) {
                      _controller.nextPage(
                          duration: Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    } else {
                      // Navigasi ke halaman berikutnya
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.indigo,
                    padding:
                        EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text("Selanjutnya"),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_pages.length, (i) {
        return AnimatedContainer(
          duration: Duration(milliseconds: 300),
          margin: EdgeInsets.symmetric(horizontal: 4),
          height: 6,
          width: _currentIndex == i ? 20 : 6,
          decoration: BoxDecoration(
            color: _currentIndex == i ? Colors.indigo : Colors.grey.shade300,
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}
