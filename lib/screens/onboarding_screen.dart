import 'package:flutter/material.dart';
import 'login_screen.dart';

class OnboardingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: Text("Get Started"),
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
          ),
        ),
      ),
    );
  }
}
