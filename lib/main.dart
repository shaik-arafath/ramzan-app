import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/prayer_time_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';
import 'providers/cart_provider.dart';
import 'providers/auth_provider.dart';
import 'providers/wishlist_provider.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  // Keep splash screen visible while initializing
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://eiocioyxmrywqwilxxho.supabase.co',
    anonKey: 'sb_publishable_YUSUwyG-hlJ5eulkxcRjzA_Bvm5VuCR',
  );

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize prayer time service
  final prayerTimeService = PrayerTimeService(notificationService);

  // Remove splash screen after initialization
  FlutterNativeSplash.remove();

  runApp(MyApp(
    prayerTimeService: prayerTimeService,
  ));
}

class MyApp extends StatelessWidget {
  final PrayerTimeService prayerTimeService;

  const MyApp({super.key, required this.prayerTimeService});

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
        home: const HomeScreen(),
      ),
    );
  }
}
