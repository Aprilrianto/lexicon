import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'onboarding_screen.dart';

void main() {
  runApp(LexiconApp());
}

class LexiconApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lexicon',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => SplashScreen(),
        '/onboarding': (context) => OnboardingScreen(),
      },
    );
  }
}
