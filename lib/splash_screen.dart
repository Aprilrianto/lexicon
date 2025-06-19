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
        '/home_screen',
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
            // Logo aplikasi
            Center(
              child: Image.asset('assets/logo.png', width: 200, height: 200),
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
