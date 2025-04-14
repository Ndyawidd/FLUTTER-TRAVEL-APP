import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

import 'presentation/pages/admin/review/review.dart';

import 'presentation/pages/splash/splash.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
// import 'presentation/pages/user/home/home.dart';
// import 'presentation/pages/booking/booking.dart';
// import 'presentation/pages/wishlist/wishlist.dart';
// import 'presentation/pages/feedback/feedback.dart';
import 'presentation/pages/admin/order/order.dart';
// import 'presentation/pages/admin/review/review.dart';
import 'presentation/pages/admin/ticket/ticket.dart';
// import 'presentation/pages/admin/ticket/ticketdetail.dart';


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
        // Splash & Auth
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),

        // User Pages (aktifkan jika sudah dibuat)
        // AppRoutes.home: (_) => const HomePage(),
        // AppRoutes.booking: (_) => const BookingPage(),
        // AppRoutes.wishlist: (_) => const WishlistPage(),
        // AppRoutes.feedback: (_) => const FeedbackPage(),
        // AppRoutes.profile: (_) => const ProfilePage(),

        // Admin Pages
        AppRoutes.adminTicket: (_) => const TicketPage(),
        // AppRoutes.adminDetailTicket: (_) => const TicketDetailPage(),
        AppRoutes.adminOrder: (_) => const OrderPage(),
        // AppRoutes.adminReview: (_) => const ReviewPage(),

      },
    );
  }
}
