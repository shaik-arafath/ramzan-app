import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/prayer_time_service.dart';
import 'services/notification_service.dart';
import 'screens/splash_page.dart';
import 'screens/home_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wishlist_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Supabase must be ready before the providers start
  try {
    await Supabase.initialize(
      url: 'https://eiocioyxmrywqwilxxho.supabase.co',
      anonKey: 'sb_publishable_YUSUwyG-hlJ5eulkxcRjzA_Bvm5VuCR',
    ).timeout(const Duration(seconds: 8));
  } catch (e) {
    debugPrint('Supabase error: $e');
  }

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final NotificationService notificationService = NotificationService();
  late final PrayerTimeService prayerTimeService =
      PrayerTimeService(notificationService);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: prayerTimeService),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        title: 'Halal World',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF0D4F2E),
            secondary: const Color(0xFFD4AF37),
            surface: const Color(0xFF0A3D24),
            onPrimary: Colors.white,
            onSecondary: Colors.black,
            onSurface: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFF0A2E1C),
        ),
        home: SplashPage(notificationService: notificationService),
      ),
    );
  }
}
