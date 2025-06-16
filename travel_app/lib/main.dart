import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'routes/app_routes.dart';
import 'presentation/pages/splash/splash.dart';
import 'presentation/pages/auth/login_page.dart';
import 'presentation/pages/auth/register_page.dart';
import 'presentation/pages/user/home/home.dart';
import 'presentation/pages/user/home/top_up.dart';
import 'presentation/pages/admin/order/order.dart';
import 'presentation/pages/admin/review/review.dart';
import 'presentation/pages/admin/ticket/ticket.dart';
import 'presentation/pages/user/history/history.dart';
import 'presentation/pages/user/home/reviews_list.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'presentation/pages/user/home/home.dart'; // Or your initial page

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      // Handle notification taps here if needed
      if (notificationResponse.payload != null) {
        debugPrint('notification payload: ${notificationResponse.payload}');
        // You could navigate to a specific page based on the payload
      }
    },
  );

  await dotenv.load(fileName: ".env");
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

        // User Pages
        '/user/home': (_) => const HomePage(),
        AppRoutes.topup: (_) => TopUpPage(),

        // Admin Pages
        AppRoutes.adminTicket: (_) => const TicketPage(),
        AppRoutes.adminOrder: (_) => const OrderPage(),
        AppRoutes.adminReview: (_) => const ReviewManagementPage(),

        // Static User Pages
        '/history': (_) => const HistoryPage(),
      },

      // Dynamic Routing (untuk /detail/{ticketId})
      onGenerateRoute: (settings) {
        if (settings.name != null && settings.name!.startsWith('/detail/')) {
          final idStr = settings.name!.replaceFirst('/detail/', '');
          final ticketId = int.tryParse(idStr);

          if (ticketId != null) {
            return MaterialPageRoute(
              builder: (_) => ReviewsListPage(ticketId: ticketId),
            );
          }
        }

        // Default jika route tidak ditemukan
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text("Halaman tidak ditemukan")),
          ),
        );
      },
    );
  }
}
