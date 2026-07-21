import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;

import 'package:notarytrackapp/main.dart';
import 'package:notarytrackapp/features/notification/view/reminder_ring_screen.dart';

@pragma('vm:entry-point')
void notificationTapBackgroundHandler(NotificationResponse response) {
  NotificationService._handleTap(response);
}

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

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleTap,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackgroundHandler,
    );

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();

    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    _initialized = true;
  }

  // ================= HANDLER TAP NOTIFIKASI =================
  static void _handleTap(NotificationResponse response) {
    final payloadStr = response.payload;
    if (payloadStr == null || payloadStr.isEmpty) return;

    try {
      final data = jsonDecode(payloadStr) as Map<String, dynamic>;
      final isRing = data['isRing'] == true;
      if (!isRing) return;

      Future.delayed(const Duration(milliseconds: 300), () {
        navigatorKey.currentState?.push(
          MaterialPageRoute(
            builder: (_) => ReminderRingScreen(
              title: data['title'] ?? 'Pengingat',
              subtitle: data['subtitle'] ?? '',
              clientName: data['clientName'] ?? '',
              location: data['location'] ?? '',
              scheduledDateIso: data['scheduledDate'] ?? '',
            ),
          ),
        );
      });
    } catch (e) {
      debugPrint('Gagal parse payload notifikasi: $e');
    }
  }

  // ================= TES NOTIFIKASI INSTAN =================
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    final vibrationPattern = Int64List.fromList([0, 1000, 500, 1000]);

    await _plugin.show(
      88888,
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

  // ================= JADWALKAN 1 NOTIFIKASI =================
  Future<void> scheduleDeadlineNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    required bool isRing,
    Map<String, dynamic>? payloadData,
  }) async {
    if (scheduledDate.isBefore(DateTime.now())) return;

    final vibrationPattern = isRing
        ? Int64List.fromList([0, 1000, 500, 1000, 500, 1000, 500, 1000])
        : Int64List.fromList([0, 500, 250, 500]);

    final payload = jsonEncode({
      'isRing': isRing,
      'title': title,
      ...?payloadData,
    });

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      NotificationDetails(
        android: AndroidNotificationDetails(
          isRing ? 'ring_channel' : 'deadline_channel',
          isRing ? 'Dering Pengingat' : 'Deadline & Janji Temu',
          channelDescription: isRing
              ? 'Notifikasi dering saat waktu janji temu / deadline tiba'
              : 'Notifikasi deadline dokumen dan janji temu',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: isRing,
          enableVibration: true,
          vibrationPattern: vibrationPattern,
          category: isRing ? AndroidNotificationCategory.alarm : null,
          ongoing: isRing,
          autoCancel: !isRing,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          interruptionLevel: InterruptionLevel.critical,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // ================= JADWALKAN PENGINGAT JANJI TEMU =================
  Future<void> scheduleAppointmentReminders({
    required int baseId,
    required String clientName,
    required String location,
    required String message,
    required DateTime appointmentTime,
  }) async {
    final jamMenit =
        "${appointmentTime.hour.toString().padLeft(2, '0')}:${appointmentTime.minute.toString().padLeft(2, '0')}";
    final tanggal =
        "${appointmentTime.day}/${appointmentTime.month}/${appointmentTime.year}";

    final basePayload = {
      'clientName': clientName,
      'location': location,
      'scheduledDate': appointmentTime.toIso8601String(),
    };

    final h1 = DateTime(
        appointmentTime.year, appointmentTime.month, appointmentTime.day - 1, 8, 0);
    if (h1.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 1,
        title: 'Pengingat Janji Temu Besok',
        body: 'Besok jam $jamMenit ada janji temu dengan $clientName. $message',
        scheduledDate: h1,
        isRing: false,
        payloadData: {...basePayload, 'subtitle': 'Besok, $jamMenit'},
      );
    }

    final h1hour = appointmentTime.subtract(const Duration(hours: 1));
    if (h1hour.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 2,
        title: 'Janji Temu 1 Jam Lagi',
        body: '1 jam lagi janji temu dengan $clientName. $message',
        scheduledDate: h1hour,
        isRing: false,
        payloadData: {...basePayload, 'subtitle': '1 jam lagi'},
      );
    }

    final h10m = appointmentTime.subtract(const Duration(minutes: 10));
    if (h10m.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 3,
        title: '🔔 Janji Temu 10 Menit Lagi!',
        body: 'Segera bersiap, 10 menit lagi janji temu dengan $clientName.',
        scheduledDate: h10m,
        isRing: true,
        payloadData: {...basePayload, 'subtitle': '10 menit lagi'},
      );
    }

    if (appointmentTime.isAfter(DateTime.now())) {
      await scheduleDeadlineNotification(
        id: baseId + 4,
        title: '🔔 Janji Temu Dimulai!',
        body: 'Janji temu dengan $clientName pada $tanggal jam $jamMenit. $message',
        scheduledDate: appointmentTime,
        isRing: true,
        payloadData: {...basePayload, 'subtitle': 'Sekarang, $jamMenit'},
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
      final isRing = h == 0;

      final title = isRing ? '⏰🔔 Deadline Hari Ini!' : '📌 Deadline Mendekat';
      final body = isRing
          ? 'Deadline HARI INI: $documentType - $clientName'
          : 'H-$h: $documentType milik $clientName harus selesai';

      await scheduleDeadlineNotification(
        id: notifId,
        title: title,
        body: body,
        scheduledDate: notifDate,
        isRing: isRing,
        payloadData: {
          'clientName': clientName,
          'location': documentType,
          'subtitle': isRing ? 'Hari ini' : 'H-$h',
          'scheduledDate': deadline.toIso8601String(),
        },
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