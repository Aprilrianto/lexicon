import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart'; // Tambahkan ini

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://dwdmlxchudptzhurnker.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImR3ZG1seGNodWRwdHpodXJua2VyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTAyNDkxOTAsImV4cCI6MjA2NTgyNTE5MH0.0X_m0hQipNP2CBzJ3hWeZEDBKHcvTMZe8GD47RR85tM',
  );
  runApp(const LexiconApp());
}

class LexiconApp extends StatelessWidget {
  const LexiconApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lexicon Novel',
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: session != null ? '/home' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(), // ✅ Tambahkan route profile
      },
    );
  }
}
