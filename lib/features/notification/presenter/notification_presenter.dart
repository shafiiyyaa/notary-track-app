import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/notification_model.dart';
import '../view/notification_view.dart';
import '../services/notification_service.dart';

class NotificationPresenter {
  final NotificationViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  NotificationPresenter(this._view);

  Future<void> loadNotifications() async {
    try {
      List<NotificationModel> list = [];

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

        if (remainingDays >= 0 && remainingDays <= 7) {
          list.add(NotificationModel(
            id: docId,
            title: "Deadline $documentType",
            clientName: clientName,
            scheduledDate: deadline,
            remainingDays: remainingDays,
            isManual: false,
          ));
        }
      }

      // 2. AMBIL DATA JANJI TEMU MANUAL DARI TABEL NOTIFICATIONS
      final manualResponse = await _supabase
          .from('notifications')
          .select('id, title, message, scheduled_at, clients(name)')
          .gte('scheduled_at', DateTime.now().toIso8601String()) 
          .order('scheduled_at', ascending: true);

      for (final item in manualResponse) {
        final schedDate = DateTime.parse(item['scheduled_at']);
        final remainingDays = schedDate.difference(DateTime.now()).inDays;
        
        if (remainingDays >= 0 && remainingDays <= 7) {
          if (schedDate.isAfter(DateTime.now())) {
            final notifIdInDb = item['id'] as int;
            int baseId = notifIdInDb % 100000;
            
            await NotificationService().scheduleAppointmentReminders(
              baseId: baseId,
              clientName: item['clients']?['name'] ?? '',
              message: item['message'] ?? '',
              appointmentTime: schedDate,
            );
          }

          list.add(NotificationModel(
            id: item['id'] as int,
            title: item['title'] ?? 'Pengingat',
            clientName: item['clients']?['name'] ?? '',
            scheduledDate: schedDate,
            remainingDays: remainingDays,
            isManual: true,
          ));
        }
      }

      list.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      _view.displayNotifications(list);
    } catch (e) {
      debugPrint("ERROR LOAD NOTIF: $e");
    }
  }
}