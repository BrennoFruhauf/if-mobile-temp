import 'package:flutter/material.dart';
import 'package:laura/constants/routes.dart';
import 'package:laura/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final AuthService _authService = AuthService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();

    _auth.authStateChanges().listen((User? user) async {
      if (user == null) {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, Routes.login);
        }
      } else {
        if (context.mounted) {
          Navigator.pushReplacementNamed(context, Routes.home);
        }
      }
    });

    _checkLoginStatus();
  }

  void _checkLoginStatus() async {
    bool hasUser = await _authService.hasUserLogged();

    if (context.mounted) {
      if (hasUser) {
        Navigator.pushReplacementNamed(context, Routes.home);
      } else {
        Navigator.pushReplacementNamed(context, Routes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
