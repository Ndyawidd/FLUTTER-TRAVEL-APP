import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../routes/app_routes.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    final role = prefs.getString('role');
    final loginTimestamp = prefs.getInt('loginTimestamp');

    // Maksimal durasi sesi (2 minggu)
    const maxDuration = Duration(days: 14);

    await Future.delayed(
        const Duration(seconds: 3)); // biar animasi tetap jalan

    if (token != null && role != null && loginTimestamp != null) {
      final loginDate = DateTime.fromMillisecondsSinceEpoch(loginTimestamp);
      final now = DateTime.now();

      if (now.difference(loginDate) <= maxDuration) {
        // Sesi masih aktif
        if (role == 'ADMIN') {
          Navigator.pushReplacementNamed(context, AppRoutes.adminTicket);
        } else {
          Navigator.pushReplacementNamed(context, AppRoutes.homeUser);
        }
        return;
      } else {
        // Sesi kadaluarsa
        await prefs.clear();
      }
    }

    // Default: ke login page
    Navigator.pushReplacementNamed(context, AppRoutes.login);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F509A),
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                'assets/images/TripMate.jpg',
                height: 120,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.image_not_supported,
                      color: Colors.white, size: 60);
                },
              ),
              const SizedBox(height: 20),
              const Text(
                'TripMate',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Your best travel companion',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
