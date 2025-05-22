import 'package:flutter/material.dart';
import 'package:ihoo/controllers/auth_service.dart';
import 'package:lottie/lottie.dart'; // Import Lottie package

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller);
    _controller.forward();
    _checkAuthAndNavigate();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _checkAuthAndNavigate() async {
    // Minimum splash screen duration
    await Future.delayed(const Duration(seconds: 2));
    
    try {
      final bool isLoggedIn = await AuthService().isLoggedIn();
      if (!mounted) return;
      
      Navigator.pushReplacementNamed(
        context,
        isLoggedIn ? "/home" : "/login",
      );
    } catch (e) {
      print("Error checking authentication: $e");
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, "/login");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2874F0),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              const Expanded(flex: 1, child: SizedBox()), // Top spacing
              Expanded(
                flex: 3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.2),
                            spreadRadius: 5,
                            blurRadius: 15,
                          ),
                        ],
                      ),
                      child: Image.asset(
                        'assets/images/ihoo.png',
                        width: 180,
                        height: 180,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ihoo',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Your One-Stop Shopping Destination',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
              const Expanded(flex: 1, child: SizedBox()), // Bottom spacing
              // Bottom section remains unchanged
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Built ',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                  Lottie.asset(
                    'assets/images/joined.json',
                    width: 50,
                    height: 50,
                  ),
                  const Text(
                    ' with Appwrite',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
