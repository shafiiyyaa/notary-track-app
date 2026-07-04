import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin
      flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> showTestNotification() async {
  await flutterLocalNotificationsPlugin.show(
    0,
    'Test Notifikasi',
    'Notifikasi berhasil muncul 🎉',
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'deadline_channel',
        'Deadline Reminder',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
  );
}
  static Future<void> init() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings =
        InitializationSettings(
      android: androidSettings,
    );

    await flutterLocalNotificationsPlugin.initialize(
      settings,
    );

    await flutterLocalNotificationsPlugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
  }

  static Future<void> showNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'deadline_channel',
      'Deadline Reminder',
      importance: Importance.max,
      priority: Priority.high,
    );

    const NotificationDetails details =
        NotificationDetails(
      android: androidDetails,
    );

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      details,
    );


  }
}