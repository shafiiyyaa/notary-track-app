import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/dashboard_model.dart';
import '../view/dashboard_view.dart';
import '../../notification/model/notification_model.dart';

class HomePresenter {
  final HomeViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  HomePresenter(this._view);

  /// Mengambil ringkasan data dokumen untuk halaman Dashboard (Home)
  Future<void> fetchDashboardSummary() async {
  try {
    final totalRes =
        await _supabase
            .from('documents')
            .select('id');

    final completedRes =
        await _supabase
            .from('documents')
            .select('id')
            .eq('status', 'Selesai');

    final notifRes =
        await _supabase
            .from('documents')
            .select('deadline');

    int deadlineCount = 0;

    final now = DateTime.now();

    for (final item in notifRes) {
      if (item['deadline'] == null) continue;

      final deadline = DateTime.parse(item['deadline']);

      final remain =
          deadline.difference(now).inDays;

      if (remain >= 0 && remain <= 7) {
        deadlineCount++;
      }
    }

    final deadlineRes = await _supabase
    .from('documents')
    .select('deadline');

    int totalDeadline = 0;

    for (final item in deadlineRes) {
      final deadline = DateTime.parse(item['deadline']);

      final remaining =
          deadline.difference(DateTime.now()).inDays;

      if (remaining >= 0 && remaining <= 7) {
        totalDeadline++;
      }
    }

    final summary = DashboardSummary(
      totalDocuments: totalRes.length,
      totalDeadlines: totalDeadline,
      completedDocuments: completedRes.length,
    );

    _view.onSummaryLoaded(summary);
  } catch (e) {
    _view.onSummaryError(e.toString());
  }
}
  Future<void> fetchDeadlineDocuments() async {
  try {
    final response = await _supabase
        .from('documents')
        .select('''
          client_name,
          deadline,
          document_types(name)
        ''')
        .order('deadline');

    List<DeadlineItem> deadlines = [];

    for (final item in response) {
      final deadline = DateTime.parse(item['deadline']);

      final remaining =
          deadline.difference(DateTime.now()).inDays;

      if (remaining >= 0 && remaining <= 7) {
        deadlines.add(
          DeadlineItem(
            clientName: item['client_name'],
            documentType: item['document_types']['name'],
            deadline: deadline,
            remainingDays: remaining,
          ),
        );
      }
    }

    _view.onDeadlineLoaded(deadlines);
  } catch (e) {
    print(e);
  }
}
  Future<void> fetchUser() async {
  try {
    final user = _supabase.auth.currentUser;

    if (user == null) return;

    final profile =
        await _supabase
            .from('profiles')
            .select('username')
            .eq('id', user.id)
            .single();

    _view.onUserLoaded(profile['username']);
  } catch (e) {
    _view.onUserLoaded("Admin");
  }
}
Future<List<NotificationModel>> fetchUpcomingDeadlines() async {
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
      if (item['deadline'] == null) continue;

      final deadline = DateTime.parse(item['deadline']);

      final remainingDays =
          deadline.difference(DateTime.now()).inDays;

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

    list.sort(
      (a, b) =>
          a.remainingDays.compareTo(b.remainingDays),
    );

    return list;
  } catch (e) {
    return [];
  }
}
}
