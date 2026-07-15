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
      final response = await _supabase
          .from('documents')
          .select('''
            id,
            client_name,
            deadline,
            document_types(name)
          ''')
          .order('deadline', ascending: true);

      List<NotificationModel> list = [];

      for (final item in response) {
        final deadline = DateTime.parse(item['deadline']);
        final remainingDays = deadline.difference(DateTime.now()).inDays;

        final docId = item['id'] as int;
        final clientName = item['client_name'] ?? '';
        final documentType = item['document_types']?['name'] ?? '';

        // Jadwalkan push notification HP (H-7, H-3, H-1, H-0)
        // aman dipanggil berkali-kali, notif lama otomatis ketimpa
        // karena id-nya sama (docId + milestone)
        await NotificationService().scheduleForDocument(
          docId: docId,
          clientName: clientName,
          documentType: documentType,
          deadline: deadline,
        );

        // tampilkan hanya deadline 7 hari ke depan di list dalam app
        if (remainingDays >= 0 && remainingDays <= 7) {
          list.add(
            NotificationModel(
              id: docId,
              clientName: clientName,
              documentType: documentType,
              deadline: deadline,
              remainingDays: remainingDays,
            ),
          );
        }
      }

      list.sort((a, b) => a.remainingDays.compareTo(b.remainingDays));

      _view.displayNotifications(list);
    } catch (e) {
      print(e);
    }
  }
}