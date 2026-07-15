// LOKASI FILE: lib/services/notification_service.dart
// (buat folder "services" kalau belum ada)

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

  /// Panggil sekali di main.dart sebelum runApp()
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

    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: (response) {
        // Tap notifikasi ditangani di sini kalau nanti mau
        // navigasi ke halaman tertentu. payload: response.payload
      },
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.requestNotificationsPermission();
    await android?.requestExactAlarmsPermission();

    _initialized = true;
  }

  /// Jadwalkan satu notifikasi pada tanggal tertentu.
  /// id harus unik per (dokumen, jenis-h-berapa).
  Future<void> scheduleDeadlineNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // skip kalau waktunya udah lewat, biar gak error
    if (scheduledDate.isBefore(DateTime.now())) return;

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'deadline_channel',
          'Deadline Dokumen',
          channelDescription: 'Notifikasi deadline dokumen yang mendekat',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
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

  /// Jadwalkan set lengkap H-7, H-3, H-1, H-0 untuk satu dokumen.
  /// Panggil ini tiap kali data dokumen dimuat / dibuat / diedit.
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
        9, // jam 9 pagi, ganti kalau mau jam lain
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

  /// Batalkan semua notifikasi terjadwal untuk satu dokumen
  /// (panggil kalau dokumen dihapus / deadline berubah, biar gak dobel)
  Future<void> cancelForDocument(int docId) async {
    for (final h in [7, 3, 1, 0]) {
      await _plugin.cancel(_makeId(docId, h));
    }
  }

  int _makeId(int docId, int h) => ('$docId-$h').hashCode & 0x7fffffff;
}