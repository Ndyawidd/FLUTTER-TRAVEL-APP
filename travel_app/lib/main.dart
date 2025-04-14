import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'presentation/pages/admin/review/review.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Travel App',
      debugShowCheckedModeBanner: false,
      initialRoute: AppRoutes.adminReview, // Langsung ke halaman review
      routes: {
        AppRoutes.adminReview: (context) => const ReviewManagementPage(),
      },
    );
  }
}
