import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/dashboard_model.dart';
import '../view/dashboard_view.dart';

class HomePresenter {
  final HomeViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  HomePresenter(this._view);

  // ⚡ FUNGSI BANTU: Parse waktu dari Supabase supaya jamnya sesuai WIB (tidak +7 jam)
  DateTime _parseTz(dynamic input) {
    if (input == null) return DateTime.now();
    String str = input.toString();
    DateTime dt = DateTime.parse(str);
    if (str.contains('Z') || str.contains('+00:00')) {
      return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
    }
    return dt;
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

        bool isLate = false;
        final deadlineStr = doc['deadline'];
        if (deadlineStr != null && status != 'Selesai' && status != 'Batal') {
          // ⚡ GUNAKAN FUNGSI WIB DI SINI
          final deadlineDate = _parseTz(deadlineStr);
          if (deadlineDate.isBefore(today)) {
            terlambat++;
            isLate = true;
          }
        }

        // ⚡ MASUKKAN STATUS TERLAMBAT KE PIE CHART
        final effectiveStatus = isLate ? 'Terlambat' : status;
        statusComposition[effectiveStatus] = (statusComposition[effectiveStatus] ?? 0) + 1;
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

  Future<void> fetchPriorityData() async {
    try {
      final data = await _supabase.from('documents').select('''
            clients(name),
            deadline,
            status,
            kesepakatan_biaya,
            uang_muka_jumlah,
            tambahan_jumlah,
            document_types(name)
          ''');

      final docs = List<Map<String, dynamic>>.from(data);
      final now = DateTime.now();
      final todayDate = DateTime(now.year, now.month, now.day);

      final mendekati = <PriorityDeadlineItem>[];
      final terlambat = <PriorityDeadlineItem>[];
      final belumLunas = <UnpaidItem>[];

      for (final doc in docs) {
        final status = doc['status'] ?? 'Belum Diproses';
        final typeName = doc['document_types']?['name'] ?? '-';
        final clientName = doc['clients']?['name'] ?? '-';

        if (status != 'Selesai' && status != 'Batal') {
          final deadlineStr = doc['deadline'];
          if (deadlineStr != null) {
            // ⚡ GUNAKAN FUNGSI WIB DI SINI JUGA
            final deadlineDate = _parseTz(deadlineStr);
            
            final remaining = deadlineDate.difference(todayDate).inDays;
            final item = PriorityDeadlineItem(
              clientName: clientName,
              documentType: typeName,
              deadline: deadlineDate,
              remainingDays: remaining,
            );
            
            // ⚡ CEK JUGA JAM NYA (KALAU HARI INI TAPI JAMNYA SUDAH LEWAT = TELAT)
            if (deadlineDate.isBefore(now)) {
              terlambat.add(item);
            } else if (remaining <= 14) {
              mendekati.add(item);
            }
          }
        }

        final kesepakatan = (doc['kesepakatan_biaya'] as num?)?.toDouble() ?? 0;
        final uangMuka = (doc['uang_muka_jumlah'] as num?)?.toDouble() ?? 0;
        final tambahan = (doc['tambahan_jumlah'] as num?)?.toDouble() ?? 0;
        final totalMasuk = uangMuka + tambahan;

        if (kesepakatan > 0 && totalMasuk < kesepakatan) {
          belumLunas.add(UnpaidItem(
            clientName: clientName,
            documentType: typeName,
            sisaTagihan: kesepakatan - totalMasuk,
          ));
        }
      }

      // Urutkan dari paling telat
      terlambat.sort((a, b) => a.deadline.compareTo(b.deadline));
      // Urutkan dari paling mendekati deadline
      mendekati.sort((a, b) => a.deadline.compareTo(b.deadline));

      _view.onPriorityLoaded(mendekati, terlambat, belumLunas);
    } catch (e) {
      debugPrint('ERROR FETCH PRIORITY: $e');
    }
  }
}