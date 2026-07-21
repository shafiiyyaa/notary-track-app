import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/notification_model.dart';
import '../view/notification_view.dart';
import '../services/notification_service.dart';
import '../services/notification_dismiss_service.dart';

class NotificationPresenter {
  final NotificationViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;
  final NotificationDismissService _dismissService = NotificationDismissService();

  NotificationPresenter(this._view);

  Future<void> loadNotifications() async {
    try {
      List<NotificationModel> list = [];
      final dismissedKeys = await _dismissService.getDismissedKeys();

      // 1. AMBIL DATA DEADLINE DARI TABEL DOCUMENTS (Otomatis)
      final docResponse = await _supabase
          .from('documents')
          .select('id, deadline, status, clients(name), document_types(name)')
          .order('deadline', ascending: true);

      for (final item in docResponse) {
        final deadline = DateTime.parse(item['deadline']);
        final remainingDays = deadline.difference(DateTime.now()).inDays;

        final docId = item['id'] as int;
        final status = item['status'] ?? 'Belum Diproses';
        final clientName = item['clients']?['name'] ?? '';
        final documentType = item['document_types']?['name'] ?? '';

        if (status == 'Selesai' || status == 'Batal') {
          await NotificationService().cancelForDocument(docId);
          continue;
        }

        await NotificationService().scheduleForDocument(
          docId: docId,
          clientName: clientName,
          documentType: documentType,
          deadline: deadline,
        );

        final key = NotificationDismissService.buildKey(id: docId, isManual: false);
        if (dismissedKeys.contains(key)) continue;

        if (remainingDays >= 0 && remainingDays <= 14) {
          list.add(NotificationModel(
            id: docId,
            title: "Deadline $documentType",
            clientName: clientName,
            location: documentType,
            description:
                'Deadline dokumen pada ${deadline.day}/${deadline.month}/${deadline.year}',
            scheduledDate: deadline,
            remainingDays: remainingDays,
            isManual: false,
          ));
        }
      }

      // 2. AMBIL DATA JANJI TEMU MANUAL DARI TABEL NOTIFICATIONS
      final manualResponse = await _supabase
          .from('notifications')
          .select('id, title, message, location, scheduled_at, clients(name)')
          .gte('scheduled_at', DateTime.now().toUtc().toIso8601String())
          .order('scheduled_at', ascending: true);

      for (final item in manualResponse) {
        final schedDate = DateTime.parse(item['scheduled_at']).toLocal();
        final remainingDays = schedDate.difference(DateTime.now()).inDays;
        final location = item['location'] ?? '';
        final notifIdInDb = item['id'] as int;

        final key = NotificationDismissService.buildKey(id: notifIdInDb, isManual: true);
        if (dismissedKeys.contains(key)) continue;

        if (remainingDays >= 0 && remainingDays <= 7) {
          if (schedDate.isAfter(DateTime.now())) {
            int baseId = notifIdInDb % 100000;

            await NotificationService().scheduleAppointmentReminders(
              baseId: baseId,
              clientName: item['clients']?['name'] ?? '',
              location: location,
              message: item['message'] ?? '',
              appointmentTime: schedDate,
            );
          }

          list.add(NotificationModel(
            id: notifIdInDb,
            title: item['title'] ?? 'Pengingat',
            clientName: item['clients']?['name'] ?? '',
            location: location,
            description: item['message'] ?? '',
            scheduledDate: schedDate,
            remainingDays: remainingDays,
            isManual: true,
          ));
        }
      }

      // 3. URUTKAN BERDASARKAN WAKTU TERDEKAT
      list.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      _view.displayNotifications(list);
    } catch (e) {
      debugPrint("ERROR LOAD NOTIF: $e");
    }
  }

  Future<void> dismissNotification(NotificationModel item) async {
    await _dismissService.dismiss(id: item.id, isManual: item.isManual);
    await loadNotifications();
  }
}