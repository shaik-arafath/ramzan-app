import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;

class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  final SupabaseClient _supabase = Supabase.instance.client;

  // Admin email for payment notifications
  static const String adminEmail = 'arafathshaik121@gmail.com';

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

    // Create order notification channel
    const orderChannel = AndroidNotificationChannel(
      'order_channel',
      'Order Updates',
      description: 'Notifications for order status and payment updates',
      importance: Importance.high,
      playSound: true,
    );

    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(orderChannel);
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

  // Send payment notification to admin (email)
  Future<void> sendPaymentNotificationToAdmin({
    required String orderId,
    required String customerName,
    required double amount,
  }) async {
    try {
      // Using Supabase Edge Function or a free email service
      // For now, we'll use a simple approach with Supabase
      // In production, you'd use a proper email service like SendGrid, Mailgun, etc.

      final emailSubject = 'New Payment Received - Order #$orderId';
      final emailBody = '''
      New Payment Received
      
      Order ID: $orderId
      Customer: $customerName
      Amount: ₹${(amount * 83).toStringAsFixed(2)}
      
      Please review and confirm the payment in the admin panel.
      ''';

      print('Sending email to $adminEmail: $emailSubject');
      print('Email body: $emailBody');

      // TODO: Integrate with actual email service
      // Options:
      // 1. Supabase Edge Functions with Resend/SendGrid
      // 2. EmailJS (free tier available)
      // 3. Formspree (free tier)
      // 4. Mailgun (free tier)

      // For now, just log it
      print('Payment notification sent to admin');
    } catch (e) {
      print('Error sending payment notification: $e');
    }
  }

  // Send in-app notification to customer
  Future<void> sendOrderNotificationToCustomer({
    required String title,
    required String body,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'order_channel',
        'Order Updates',
        channelDescription: 'Notifications for order status and payment updates',
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
    } catch (e) {
      print('Error sending order notification: $e');
    }
  }

  // Notify admin of new order
  Future<void> notifyAdminOfNewOrder({
    required String orderId,
    required String customerName,
    required double amount,
  }) async {
    await sendPaymentNotificationToAdmin(
      orderId: orderId,
      customerName: customerName,
      amount: amount,
    );
  }

  // Notify customer of payment confirmation
  Future<void> notifyPaymentConfirmed({
    required String orderId,
  }) async {
    await sendOrderNotificationToCustomer(
      title: 'Payment Confirmed!',
      body: 'Your payment for order #$orderId has been confirmed. Your order is being processed.',
    );
  }

  // Notify customer of order status update
  Future<void> notifyOrderStatusUpdate({
    required String orderId,
    required String status,
  }) async {
    String title = 'Order Status Update';
    String body = 'Your order #$orderId status has been updated to: $status';

    await sendOrderNotificationToCustomer(
      title: title,
      body: body,
    );
  }
}
