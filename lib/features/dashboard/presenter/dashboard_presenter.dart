import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/dashboard_model.dart';
import '../view/dashboard_view.dart';

class HomePresenter {
  final HomeViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  HomePresenter(this._view);

  Future<void> fetchDashboardSummary() async {
    try {
      // ⚡ TAMBAHKAN document_income_details(amount) UNTUK HITUNG CICILAN/TAMBAHAN
      final data = await _supabase.from('documents').select('''
            status,
            deadline,
            kesepakatan_biaya,
            uang_muka_jumlah,
            document_income_details(amount),
            document_types(name)
          ''');

      final docs = List<Map<String, dynamic>>.from(data);

      int aktif = 0, selesai = 0, tertunda = 0, batal = 0, terlambat = 0;
      double totalNilaiJasa = 0, totalLunas = 0;
      final statusComposition = <String, int>{};
      final categoryComposition = <String, int>{};

      for (final doc in docs) {
        final status = doc['status'] ?? 'Belum Diproses';
        final typeName = doc['document_types']?['name'] ?? 'Lainnya';
        categoryComposition[typeName] =
            (categoryComposition[typeName] ?? 0) + 1;

        if (status == 'Diproses') aktif++;
        if (status == 'Selesai') selesai++;
        if (status == 'Tertunda') tertunda++;
        if (status == 'Batal') batal++;

        final kesepakatan = (doc['kesepakatan_biaya'] as num?)?.toDouble() ?? 0;
        final uangMuka = (doc['uang_muka_jumlah'] as num?)?.toDouble() ?? 0;

        // ⚡ JUMLAHKAN SEMUA PEMBAYARAN TAMBAHAN DARI TABEL RELASI
        double tambahan = 0;
        if (doc['document_income_details'] != null) {
          for (var inc in doc['document_income_details'] as List) {
            tambahan += (inc['amount'] as num?)?.toDouble() ?? 0;
          }
        }

        final totalMasukPemohon = uangMuka + tambahan;

        totalNilaiJasa += kesepakatan;
        if (kesepakatan > 0 && totalMasukPemohon >= kesepakatan) {
          totalLunas += kesepakatan;
        }

        bool isLate = false;
        if (status != 'Selesai' && status != 'Batal') {
          final deadlineStr = doc['deadline'] as String?;
          if (deadlineStr != null) {
            final deadlineDate = DateTime.tryParse(deadlineStr);
            if (deadlineDate != null && deadlineDate.isBefore(DateTime.now())) {
              isLate = true;
            }
          }
        }

        if (isLate) terlambat++;

        final effectiveStatus = isLate ? 'Terlambat' : status;
        statusComposition[effectiveStatus] =
            (statusComposition[effectiveStatus] ?? 0) + 1;
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
      // ⚡ TAMBAHKAN document_income_details(amount) UNTUK HITUNG CICILAN/TAMBAHAN
      final data = await _supabase.from('documents').select('''
            clients(name),
            deadline,
            status,
            kesepakatan_biaya,
            uang_muka_jumlah,
            document_income_details(amount),
            document_types(name)
          ''');

      final docs = List<Map<String, dynamic>>.from(data);

      final mendekati = <PriorityDeadlineItem>[];
      final terlambat = <PriorityDeadlineItem>[];
      final belumLunas = <UnpaidItem>[];

      for (final doc in docs) {
        final status = doc['status'] ?? 'Belum Diproses';
        final typeName = doc['document_types']?['name'] ?? '-';
        final clientName = doc['clients']?['name'] ?? '-';

        if (status != 'Selesai' && status != 'Batal') {
          final deadlineStr = doc['deadline'] as String?;
          final deadlineDate = DateTime.tryParse(deadlineStr ?? '');

          if (deadlineDate != null) {
            final now = DateTime.now();
            final diff = deadlineDate
                .difference(DateTime(now.year, now.month, now.day))
                .inDays;

            final item = PriorityDeadlineItem(
              clientName: clientName,
              documentType: typeName,
              deadline: deadlineDate,
              remainingDays: diff,
            );

            bool isLate = deadlineDate.isBefore(DateTime.now());

            if (isLate) {
              terlambat.add(item);
            } else if (diff <= 14) {
              mendekati.add(item);
            }
          }
        }

        final kesepakatan = (doc['kesepakatan_biaya'] as num?)?.toDouble() ?? 0;
        final uangMuka = (doc['uang_muka_jumlah'] as num?)?.toDouble() ?? 0;

        // ⚡ JUMLAHKAN SEMUA PEMBAYARAN TAMBAHAN DARI TABEL RELASI
        double tambahan = 0;
        if (doc['document_income_details'] != null) {
          for (var inc in doc['document_income_details'] as List) {
            tambahan += (inc['amount'] as num?)?.toDouble() ?? 0;
          }
        }

        final totalMasuk = uangMuka + tambahan;

        // ⚡ CEK JIKA UANG MASUK MASIH KURANG DARI KESEPAKATAN
        if (kesepakatan > 0 && totalMasuk < kesepakatan) {
          belumLunas.add(
            UnpaidItem(
              clientName: clientName,
              documentType: typeName,
              sisaTagihan: kesepakatan - totalMasuk,
            ),
          );
        }
      }

      terlambat.sort((a, b) => a.deadline.compareTo(b.deadline));
      mendekati.sort((a, b) => a.deadline.compareTo(b.deadline));

      _view.onPriorityLoaded(mendekati, terlambat, belumLunas);
    } catch (e) {
      debugPrint('ERROR FETCH PRIORITY: $e');
    }
  }
}
