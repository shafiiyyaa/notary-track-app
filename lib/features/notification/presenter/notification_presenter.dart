import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/notification_model.dart';
import '../view/notification_view.dart';

class NotificationPresenter {
  final NotificationViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  NotificationPresenter(this._view);

  Future<void> loadNotifications() async {
    try {
      final response = await _supabase
          .from('documents')
          .select('''
            client_name,
            deadline,
            document_types(name)
          ''')
          .order('deadline', ascending: true);

      List<NotificationModel> list = [];

      for (final item in response) {
        final deadline = DateTime.parse(item['deadline']);

        final remainingDays =
            deadline.difference(DateTime.now()).inDays;

        // tampilkan hanya deadline 7 hari ke depan
        if (remainingDays >= 0 && remainingDays <= 7) {
          list.add(
            NotificationModel(
              clientName: item['client_name'] ?? '',
              documentType:
                  item['document_types']?['name'] ?? '',
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