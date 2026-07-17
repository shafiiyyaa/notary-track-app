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
      // Tambahkan kolom 'status' di select
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

        // Jika dokumen sudah Selesai atau Batal, hapus alarm notif di HP dan SKIP (jangan dimasukkan ke list)
        if (status == 'Selesai' || status == 'Batal') {
          await NotificationService().cancelForDocument(docId);
          continue; // Loncati kode di bawahnya, jangan masukin ke list
        }

        // Jadwalkan notif HP H-7, H-3, H-1, H-0
        await NotificationService().scheduleForDocument(
          docId: docId,
          clientName: clientName,
          documentType: documentType,
          deadline: deadline,
        );

        // Tampilkan di list jika masih dalam 7 hari ke depan
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
          .gte('scheduled_at', DateTime.now().toIso8601String()) // Hanya yang belum lewat
          .order('scheduled_at', ascending: true);

      for (final item in manualResponse) {
        final schedDate = DateTime.parse(item['scheduled_at']).toLocal();
        final remainingDays = schedDate.difference(DateTime.now()).inDays;
        
        // Kalau kurang dari 7 hari lagi, masukin ke list
        if (remainingDays >= 0 && remainingDays <= 7) {
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

      // 3. URUTKAN BERDASARKAN WAKTU TERDEKAT
      list.sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

      _view.displayNotifications(list);
    } catch (e) {
      print("ERROR LOAD NOTIF: $e");
    }
  }
}