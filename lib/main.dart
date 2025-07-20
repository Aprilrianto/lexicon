import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lexiconn/models/novel.dart'; // Impor model Novel
import 'package:lexiconn/screens/admin_dashboard_screen.dart';
import 'package:lexiconn/screens/edit_profile_admin.dart';
import 'package:lexiconn/screens/forgot_pasword.dart';
import 'package:lexiconn/screens/update_password.dart';
import 'package:lexiconn/screens/verification_email.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/onboarding_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/bookmark_screen.dart';
import 'screens/chapter_read_screen.dart';
import 'screens/my_works_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/help_and_feedback_screen.dart';
import 'screens/notification_screen.dart';
import 'screens/explore_screen.dart';
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
        '/onboarding': (context) => const OnboardingScreen(),
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin_dashboard': (context) => const AdminDashboardScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/bookmarks': (context) => const BookmarkScreen(),
        '/forgotpass': (context) => const ForgotPasswordScreen(),
        '/updatepassword': (context) => const UpdatePasswordScreen(),
        '/edit-profile': (context) => const EditProfileAdminScreen(),
        '/my-works': (context) => const MyWorksScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/help': (context) => const HelpAndFeedbackScreen(),
        '/notifications': (context) => const NotificationScreen(),
        '/explore' : (context) => const ExploreScreen(),
        '/verificationemail': (context) {
          final email = ModalRoute.of(context)!.settings.arguments as String?;
          if (email != null) {
            return VerificationEmailScreen(email: email);
          }
          return const LoginScreen();
        },

        // Rute ini sekarang menerima objek Novel
        '/read': (context) {
          final args = ModalRoute.of(context)!.settings.arguments;
          if (args is Novel) {
            return ChapterReadScreen(novel: args);
          } else {
            return const Scaffold(
              body: Center(child: Text('Data novel tidak valid')),
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
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final onboardingSeen = prefs.getBool('onboarding_seen') ?? false;

    if (!onboardingSeen) {
      Navigator.pushReplacementNamed(context, '/onboarding');
      return;
    }

    final session = Supabase.instance.client.auth.currentSession;
    if (session != null) {
      try {
        final profileData =
            await Supabase.instance.client
                .from('profiles')
                .select('role')
                .eq('id', session.user.id)
                .single();

        final role =
            (profileData['role'] as String? ?? 'user').trim().toLowerCase();

        if (!mounted) return;

        if (role == 'admin') {
          Navigator.pushReplacementNamed(context, '/admin_dashboard');
        } else {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } catch (e) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      }
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
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
