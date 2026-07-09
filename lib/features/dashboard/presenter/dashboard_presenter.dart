import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/dashboard_model.dart';
import '../view/dashboard_view.dart';

class HomePresenter {
  final HomeViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  HomePresenter(this._view);

  Future<void> fetchUser() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final data = await _supabase
          .from('profiles')
          .select('username')
          .eq('id', user.id)
          .single();
      _view.onUserLoaded(data['username'] ?? 'Admin');
    } catch (e) {
      debugPrint('ERROR FETCH USER: $e');
    }
  }

  Future<void> fetchDashboardSummary() async {
    try {
      final data = await _supabase.from('documents').select('''
            status,
            deadline,
            kesepakatan_biaya,
            uang_muka_jumlah,
            tambahan_jumlah,
            document_types(name)
          ''');

      final docs = List<Map<String, dynamic>>.from(data);
      final today = DateTime.now();

      int aktif = 0, selesai = 0, tertunda = 0, batal = 0, terlambat = 0;
      double totalNilaiJasa = 0, totalLunas = 0;
      final statusComposition = <String, int>{};
      final categoryComposition = <String, int>{};

      for (final doc in docs) {
        final status = doc['status'] ?? 'Belum Diproses';
        statusComposition[status] = (statusComposition[status] ?? 0) + 1;

        final typeName = doc['document_types']?['name'] ?? 'Lainnya';
        categoryComposition[typeName] = (categoryComposition[typeName] ?? 0) + 1;

        if (status == 'Diproses') aktif++;
        if (status == 'Selesai') selesai++;
        if (status == 'Tertunda') tertunda++;
        if (status == 'Batal') batal++;

        final kesepakatan = (doc['kesepakatan_biaya'] as num?)?.toDouble() ?? 0;
        final uangMuka = (doc['uang_muka_jumlah'] as num?)?.toDouble() ?? 0;
        final tambahan = (doc['tambahan_jumlah'] as num?)?.toDouble() ?? 0;
        final totalMasukPemohon = uangMuka + tambahan;

        totalNilaiJasa += kesepakatan;
        if (kesepakatan > 0 && totalMasukPemohon >= kesepakatan) {
          totalLunas += kesepakatan;
        }

        final deadlineStr = doc['deadline'];
        if (deadlineStr != null && status != 'Selesai' && status != 'Batal') {
          final deadlineDate = DateTime.tryParse(deadlineStr);
          if (deadlineDate != null && deadlineDate.isBefore(today)) {
            terlambat++;
          }
        }
      }

      final total = docs.length;
      final progressPercent = total == 0 ? 0.0 : (selesai / total) * 100;

      final summary = DashboardSummary(
        totalDocuments: total,
        aktif: aktif,
        selesai: selesai,
        tertunda: tertunda,
        batal: batal,
        terlambat: terlambat,
        totalNilaiJasa: totalNilaiJasa,
        totalLunas: totalLunas,
        totalBelumLunas: totalNilaiJasa - totalLunas,
        progressPercent: progressPercent,
        statusComposition: statusComposition,
        categoryComposition: categoryComposition,
      );

      _view.onSummaryLoaded(summary);
    } catch (e) {
      debugPrint('ERROR FETCH SUMMARY: $e');
      _view.onSummaryError(e.toString());
    }
  }

  Future<void> fetchDeadlineDocuments() async {
    try {
      final data = await _supabase
          .from('documents')
          .select('''
            client_name,
            deadline,
            document_types(name)
          ''')
          .not('status', 'in', '("Selesai","Batal")')
          .order('deadline', ascending: true)
          .limit(5);

      final today = DateTime.now();
      final list = List<Map<String, dynamic>>.from(data).map((row) {
        final deadline = DateTime.tryParse(row['deadline'] ?? '') ?? today;
        final remaining = deadline.difference(DateTime(today.year, today.month, today.day)).inDays;
        return DeadlineItem(
          clientName: row['client_name'] ?? '',
          documentType: row['document_types']?['name'] ?? '',
          deadline: deadline,
          remainingDays: remaining,
        );
      }).toList();

      _view.onDeadlineLoaded(list);
    } catch (e) {
      debugPrint('ERROR FETCH DEADLINE: $e');
    }
  }
}