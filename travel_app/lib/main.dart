import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'presentation/pages/splash/splash.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/home/home.dart';
// import 'presentation/pages/booking/booking.dart';
// import 'presentation/pages/wishlist/wishlist.dart';
// import 'presentation/pages/feedback/feedback.dart';

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
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),
        AppRoutes.home: (_) => const HomePage(),
        // AppRoutes.booking: (_) => const BookingPage(),
        // AppRoutes.wishlist: (_) => const WishlistPage(),
        // AppRoutes.feedback: (_) => const FeedbackPage(),
      },
    );
  }
}
