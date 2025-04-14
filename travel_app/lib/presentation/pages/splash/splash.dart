import 'package:flutter/material.dart';
import '../../../routes/app_routes.dart';

class SplashPage extends StatelessWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });

    return const Scaffold(
      body: Center(child: Text('Travel App', style: TextStyle(fontSize: 24))),
    );
  }
}
