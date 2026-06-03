import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/dashboard_model.dart';
import '../view/dashboard_view.dart';

class HomePresenter {
  final HomeViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  HomePresenter(this._view);

  /// Mengambil ringkasan data dokumen untuk halaman Dashboard (Home)
  Future<void> fetchDashboardSummary() async {
    try {
      // 1. Ambil semua baris id dari tabel 'documents' untuk tahu totalnya
      final totalRes = await _supabase.from('documents').select('id');

      // 2. Ambil baris id yang kolom status-nya bernilai 'Selesai'
      final completedRes = await _supabase
          .from('documents')
          .select('id')
          .eq('status', 'Selesai');

      // 3. Bungkus hasil perhitungan ke dalam entitas DashboardSummary Model
      final summary = DashboardSummary(
        totalDocuments: totalRes.length,
        totalDeadlines: 0,
        completedDocuments: completedRes.length,
      );

      // 4. Kirim data yang berhasil diambil kembali ke halaman View (UI)
      _view.onSummaryLoaded(summary);
    } catch (e) {
      // Jika koneksi gagal atau tabel belum dibuat, kirim pesan galat ke View
      _view.onSummaryError(e.toString());
    }
  }
}
