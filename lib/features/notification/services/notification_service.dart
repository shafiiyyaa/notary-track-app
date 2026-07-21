import 'dart:typed_data';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

class NotificationService {
  static final NotificationService _instance =
      NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Jakarta'));

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(settings);

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    _initialized = true;
  }

  // ================= TES NOTIFIKASI INSTAN =================
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    await _plugin.show(
      88888, // ID sementara untuk tes
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          'instant_channel',
          'Tes Instan',
          channelDescription: 'Channel untuk tes instan',
          importance: Importance.max,
          priority: Priority.high,
          enableVibration: true,
          vibrationPattern: vibrationPattern,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  Future<void> scheduleDeadlineNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required bool isFullScreenPopup,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000]);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_channel',
          'Deadline & Janji Temu',
          channelDescription: 'Notifikasi deadline dokumen dan janji temu',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: isFullScreenPopup,
          enableVibration: true,
          vibrationPattern: vibrationPattern,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  // ================= JADWALKAN PENGINGAT JANJI TEMU =================
  Future<void> scheduleAppointmentReminders({
    required int baseId,
    required String clientName,
    required String message,
    required DateTime appointmentTime,
  }) async {
    final jamMenit = "${appointmentTime.hour.toString().padLeft(2,'0')}:${appointmentTime.minute.toString().padLeft(2,'0')}";
    final tanggal = "${appointmentTime.day}/${appointmentTime.month}/${appointmentTime.year}";
    
    final h1 = DateTime(appointmentTime.year, appointmentTime.month, appointmentTime.day - 1, 8, 0);
    if (h1.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 1,
        title: 'Pengingat Janji Temu Besok',
        body: 'Besok jam $jamMenit ada janji temu dengan $clientName. $message',
        scheduledDate: h1,
        isFullScreenPopup: false,
      );
    }

    final h1hour = appointmentTime.subtract(const Duration(hours: 1));
    if (h1hour.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 2,
        title: 'Janji Temu 1 Jam Lagi',
        body: '1 jam lagi janji temu dengan $clientName. $message',
        scheduledDate: h1hour,
        isFullScreenPopup: false,
      );
    }

    final h10m = appointmentTime.subtract(const Duration(minutes: 10));
    if (h10m.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 3,
        title: 'Janji Temu 10 Menit Lagi!',
        body: 'Segera bersiap, 10 menit lagi janji temu dengan $clientName.',
        scheduledDate: h10m,
        isFullScreenPopup: false,
      );
    }

    if (appointmentTime.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 4,
        title: '🔔 Janji Temu Dimulai!',
        body: 'Janji temu dengan $clientName pada $tanggal jam $jamMenit. $message',
        scheduledDate: appointmentTime,
        isFullScreenPopup: true,
      );
    }
  }

  // ================= JADWALKAN DEADLINE DOKUMEN =================
  Future<void> scheduleForDocument({
    required int docId,
    required String clientName,
    required String documentType,
    required DateTime deadline,
  }) async {
    const milestones = [14, 7, 3, 1, 0];

    for (final h in milestones) {
      final notifDate = DateTime(
        deadline.year,
        deadline.month,
        deadline.day - h,
        8, 
        0,
      );

      final notifId = _makeId(docId, h);

      final title = h == 0 ? '⏰ Deadline Hari Ini!' : '📌 Deadline Mendekat';
      final body = h == 0
          ? 'Deadline HARI INI: $documentType - $clientName'
          : 'H-$h: $documentType milik $clientName harus selesai';

      await scheduleDeadlineNotification(
        id: notifId,
        title: title,
        body: body,
        scheduledDate: notifDate,
        isFullScreenPopup: false,
      );
    }
  }

  Future<void> cancelForDocument(int docId) async {
    for (final h in [14, 7, 3, 1, 0]) {
      await _plugin.cancel(_makeId(docId, h));
    }
  }

  Future<void> cancelAppointmentReminders(int baseId) async {
    await _plugin.cancel(baseId + 1);
    await _plugin.cancel(baseId + 2);
    await _plugin.cancel(baseId + 3);
    await _plugin.cancel(baseId + 4);
  }

  int _makeId(int docId, int h) => ('$docId-$h').hashCode & 0x7fffffff;
}