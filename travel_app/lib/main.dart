import 'package:flutter/material.dart';
import 'routes/app_routes.dart';
import 'presentation/pages/splash/splash.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/user/home/home.dart';
import 'presentation/pages/user/home/top_up.dart';
import 'presentation/pages/admin/order/order.dart';
import 'presentation/pages/admin/review/review.dart';
import 'presentation/pages/admin/ticket/ticket.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load();
  runApp(MyApp());
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
        AppRoutes.topup: (context) => TopUpPage(),

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
