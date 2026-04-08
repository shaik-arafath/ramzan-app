import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications = 
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Initialize timezone data for scheduled notifications (Android)
    tz.initializeTimeZones();
    // Use device's local timezone; for India this is typically Asia/Kolkata.
    tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);
    
    await _notifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // If user taps the STOP action, cancel this notification.
        if (response.actionId == 'STOP_ACTION' && response.id != null) {
          await _notifications.cancel(response.id!);
        }
      },
    );

    // Create notification channels
    const androidChannel = AndroidNotificationChannel(
      'prayer_channel',
      'Prayer Times',
      description: 'Notifications for prayer times and Ramadan reminders',
      importance: Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(androidChannel);
  }

  Future<void> showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);

    await _notifications.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      details,
    );
  }

  /// Schedule a notification to show at the given local time.
  /// Works on Android even if the app is closed.
  Future<void> scheduleNotificationAt(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);
    final androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  /// Schedule an Adhan notification using the raw resource azan.mp3
  Future<void> scheduleAdhanNotificationAt(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('azan'),
      actions: const [
        AndroidNotificationAction(
          'STOP_ACTION',
          'STOP',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  /// Schedule a Siren notification using the raw resource siren.mp3
  Future<void> scheduleSirenNotificationAt(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    final tzTime = tz.TZDateTime.from(scheduledTime, tz.local);

    final androidDetails = AndroidNotificationDetails(
      'prayer_channel',
      'Prayer Times',
      channelDescription: 'Notifications for prayer times',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      sound: const RawResourceAndroidNotificationSound('siren'),
      actions: const [
        AndroidNotificationAction(
          'STOP_ACTION',
          'STOP',
          showsUserInterface: true,
          cancelNotification: true,
        ),
      ],
    );

    final details = NotificationDetails(android: androidDetails);

    await _notifications.zonedSchedule(
      id,
      title,
      body,
      tzTime,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null,
    );
  }

  Future<void> cancelNotification(int id) async {
    await _notifications.cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }
}
