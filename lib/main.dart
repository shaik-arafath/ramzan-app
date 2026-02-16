import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/prayer_time_service.dart';
import 'services/notification_service.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF1F7B4F),
            brightness: Brightness.light,
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1F7B4F),
            foregroundColor: Colors.white,
            elevation: 0,
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
