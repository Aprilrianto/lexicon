import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lexiconn/screens/forgot_pasword.dart';
import 'package:lexiconn/screens/update_password.dart';
import 'package:lexiconn/screens/verification_email.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/bookmark_screen.dart';
import 'screens/chapter_read_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dwdmlxchudptzhurnker.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3ZG1seGNodWRwdHpodXJua2VyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyNDkxOTAsImV4cCI6MjA2NTgyNTE5MH0.0X_m0hQipNP2CBzJ3hWeZEDBKHcvTMZe8GD47RR85tM',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lexicon Novel',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SplashScreen(),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/bookmarks': (context) => const BookmarkScreen(),
        '/forgotpass': (context) => const ForgotPasswordScreen(),
        '/verificationemail': (context) => const VerificationEmailScreen(),
        '/updatepassword': (context) => const UpdatePasswordScreen(),

        // Fix: Routing halaman baca bab
        '/read': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is Map<String, dynamic>) {
            return ChapterReadScreen(chapter: args);
          } else {
            return const Scaffold(
              body: Center(child: Text('Data bab tidak valid')),
            );
          }
        },
      },
    );
  }
}

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      final session = Supabase.instance.client.auth.currentSession;
      if (session != null) {
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Image(image: AssetImage('assets/logo.png'), width: 200),
      ),
    );
  }
}
