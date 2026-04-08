import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/prayer_time_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://epwhtdzdokrzrpwltvir.supabase.co',
    anonKey: 'sb_publishable_9vCD3TjH-9bESl5A4edMtw_qnCbHLE4',
  );

  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initialize();

  // Initialize prayer time service
  final prayerTimeService = PrayerTimeService(notificationService);

  runApp(MyApp(
    prayerTimeService: prayerTimeService,
  ));
}

class MyApp extends StatelessWidget {
  final PrayerTimeService prayerTimeService;

  const MyApp({super.key, required this.prayerTimeService});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: prayerTimeService,
      child: MaterialApp(
        title: 'Ramadan Planner',
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
