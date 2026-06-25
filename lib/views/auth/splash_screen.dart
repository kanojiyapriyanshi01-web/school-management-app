import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;
  late Animation<double> _scaleAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1500));
    _fadeAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn));
    _scaleAnim = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut));
    _controller.forward();
    _navigate();
  }

  Future<void> _navigate() async {
  await Future.delayed(const Duration(seconds: 2));
  if (!mounted) return;
  try {
    final auth = context.read<AuthProvider>();
    await auth.checkAuth().timeout(
      const Duration(seconds: 3),
      onTimeout: () {},
    );
    if (!mounted) return;
    if (auth.isAuthenticated) {
      switch (auth.user?.role) {
        case 'staff':   context.go('/dashboard/staff'); break;
        case 'student': context.go('/dashboard/student'); break;
        case 'parent':  context.go('/dashboard/parent'); break;
        default:        context.go('/dashboard/admin'); break;
      }
    } else {
      context.go('/login');
    }
  } catch (e) {
    if (mounted) context.go('/login');
  }
}

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0D47A1), Color(0xFF1565C0), Color(0xFF1976D2)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Center(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: ScaleTransition(
                scale: _scaleAnim,
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  // Logo
                  Container(
                    width: 120, height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withOpacity(0.3), width: 2),
                      boxShadow: [
                        BoxShadow(color: Colors.black.withOpacity(0.2),
                          blurRadius: 20, spreadRadius: 5)
                      ]),
                    child: const Icon(Icons.school, color: Colors.white, size: 60),
                  ),
                  const SizedBox(height: 30),
                  const Text('School Management',
                    style: TextStyle(color: Colors.white, fontSize: 26,
                      fontWeight: FontWeight.bold, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text('System', style: TextStyle(
                    color: Colors.white.withOpacity(0.8), fontSize: 18,
                    letterSpacing: 2)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20)),
                    child: const Text('Complete School ERP Solution',
                      style: TextStyle(color: Colors.white70, fontSize: 12))),
                  const SizedBox(height: 60),
                  // Loading indicator
                  SizedBox(width: 200,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withOpacity(0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 3,
                    )),
                  const SizedBox(height: 16),
                  Text('Loading...', style: TextStyle(
                    color: Colors.white.withOpacity(0.7), fontSize: 12)),
                  const SizedBox(height: 60),
                  // Version
                  Text('Version 1.0.0', style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 11)),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}


