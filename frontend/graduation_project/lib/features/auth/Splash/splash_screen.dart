import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:graduation_project/features/admin/admin_home/presentation/screens/admin_home_view.dart';
import 'package:graduation_project/features/auth/login/presentation/screens/login_view.dart';
import 'package:graduation_project/features/customer/home/presentation/screens/home_view.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  AnimationController? _controller;
  Animation<double>? _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller!,
      curve: Curves.easeInOut,
    );
    _controller!.forward();
    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(const Duration(seconds: 3));
    final token = await _storage.read(key: 'token');
    final role = await _storage.read(key: 'role');
    if (token != null && token.isNotEmpty) {
      if (role == 'Customer') {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const HomeView()),
          );
        }
      } else if (role == 'Admin') {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const AdminHomeView()),
          );
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LoginView()),
          );
        }
      }
    } else {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginView()),
        );
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFDAEEE4),
      body: Center(
        child: ScaleTransition(
          scale: _animation!,
          child: FadeTransition(
            opacity: _animation!,
            child: Image.asset(
              'assets/native_splash_logo.png',
              width: MediaQuery.of(context).size.width * 0.6,
            ),
          ),
        ),
      ),
    );
  }
} 