import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  @override
  _splashScreenState createState() => _splashScreenState();
}

class _splashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Mensimulasikan delay untuk splash screen
    Future.delayed(Duration(seconds: 3), () {
      // Navigasi ke halaman utama setelah delay
      Navigator.pushReplacementNamed(
        context,
        '/home',
      ); // Ganti dengan halaman tujuan yang sesuai
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Ganti dengan logo atau gambar splash screen
            Icon(Icons.book, size: 100, color: Colors.yellow),
            SizedBox(height: 24),
            // Nama aplikasi
            Text(
              'Lexicon App',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            // Loding Indicator
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
