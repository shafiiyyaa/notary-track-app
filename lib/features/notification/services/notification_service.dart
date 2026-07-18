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

  Future<void> scheduleDeadlineNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
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
          'Deadline Dokumen',
          channelDescription: 'Notifikasi deadline dokumen yang mendekat',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
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
    
    final h1 = DateTime(appointmentTime.year, appointmentTime.month, appointmentTime.day - 1, 12, 0);
    if (h1.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 1,
        title: 'Pengingat Janji Temu Besok',
        body: 'Besok jam $jamMenit bersama $clientName. $message',
        scheduledDate: h1,
      );
    }

    final h12 = appointmentTime.subtract(const Duration(hours: 12));
    if (h12.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 2,
        title: 'Pengingat Janji Temu (12 Jam Lagi)',
        body: '12 jam lagi jam $jamMenit bersama $clientName. $message',
        scheduledDate: h12,
      );
    }

    final h10m = appointmentTime.subtract(const Duration(minutes: 10));
    if (h10m.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 3,
        title: 'Janji Temu Segera Dimulai!',
        body: '10 menit lagi jam $jamMenit bersama $clientName. $message',
        scheduledDate: h10m,
      );
    }
  }

  // ================= JADWALKAN DEADLINE DOKUMEN (H-7, H-3, H-1, H-0) =================
  Future<void> scheduleForDocument({
    required int docId,
    required String clientName,
    required String documentType,
    required DateTime deadline,
  }) async {
    const milestones = [7, 3, 1, 0];

    for (final h in milestones) {
      final notifDate = DateTime(
        deadline.year,
        deadline.month,
        deadline.day - h,
        9, 
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
      );
    }
  }

  Future<void> cancelForDocument(int docId) async {
    for (final h in [7, 3, 1, 0]) {
      await _plugin.cancel(_makeId(docId, h));
    }
  }

  Future<void> cancelAppointmentReminders(int baseId) async {
    await _plugin.cancel(baseId + 1);
    await _plugin.cancel(baseId + 2);
    await _plugin.cancel(baseId + 3);
  }

  int _makeId(int docId, int h) => ('$docId-$h').hashCode & 0x7fffffff;
}