import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'presentation/pages/splash/splash.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/user/home/home.dart';
// import 'presentation/pages/booking/booking.dart';
// import 'presentation/pages/wishlist/wishlist.dart';
// import 'presentation/pages/feedback/feedback.dart';
import 'presentation/pages/admin/order/order.dart';
import 'presentation/pages/admin/review/review.dart';
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
      initialRoute: AppRoutes.splash,
      routes: {
        // Splash & Auth
        AppRoutes.splash: (_) => const SplashPage(),
        AppRoutes.login: (_) => const LoginPage(),
        AppRoutes.register: (_) => const RegisterPage(),

        // User pages
        '/user/home': (context) => const HomePage(),
        // '/destination/detail': (context) => DestinationDetailPage(
        // name: '', location: '', imageUrl: '', price: 0, // Dummy untuk compiler

        // AppRoutes.homeUser: (context) => const HomePage(),
        // AppRoutes.booking: (context) => const BookingPage(),
        // AppRoutes.wishlist: (context) => const WishlistPage(),
        // AppRoutes.feedback: (context) => const FeedbackPage(),
        // AppRoutes.profile: (context) => const ProfilePage(),

        // Admin Pages
        AppRoutes.adminTicket: (_) => const TicketPage(),
        // AppRoutes.adminDetailTicket: (_) => const TicketDetailPage(),
        AppRoutes.adminOrder: (_) => const OrderPage(),
        // AppRoutes.adminReview: (_) => const ReviewPage(),
        AppRoutes.adminReview: (_) => const ReviewManagementPage(),
      },
    );
  }
}
