import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../view/add_doc_view.dart';

class AddDocPresenter {
  final AddDocumentViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  AddDocPresenter(this._view);

  // Helper untuk bersihkan titik dari string format Rupiah
  double _cleanAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll('.', '').replaceAll(',', '.')) ?? 0;
  }

  Future<void> saveDocument({
    required String clientId,
    required String phone,
    required int documentTypeId,
    required String kategori,
    required String deadline,
    required String staffId,
    required String note,
    required double kesepakatanBiaya,
    String? uangMukaTanggal,
    required double uangMukaJumlah,
    String? tambahanTanggal,
    required double tambahanJumlah,
    String? kasBesarTanggal,
    required double kasBesarJumlah,
    required String keteranganKeuangan,
    required List<Map<String, dynamic>> incomeDetails,
    required List<Map<String, dynamic>> expenses,
    String? tanggalMasuk,
    String? uraianSingkat,
    String? nomorDokumen,
    String? dokumenDibutuhkan,
    String? dokumenDiterima,
    String? statusPembayaran,
  }) async {
    if (clientId.isEmpty || deadline.isEmpty) {
      _view.onSaveError("Klien dan Deadline wajib diisi!");
      return;
    }

    final user = _supabase.auth.currentUser;
    if (user == null) {
      _view.onSaveError("Silakan login terlebih dahulu.");
      return;
    }

    _view.showLoading();

    try {
      final inserted = await _supabase
          .from('documents')
          .insert({
            'client_id': clientId,
            'phone': phone,
            'document_type_id': documentTypeId,
            'kategori': kategori,
            'deadline': deadline,
            'notes': note,
            'status': 'Belum Diproses',
            'staff_id': staffId,
            'kesepakatan_biaya': kesepakatanBiaya,
            'uang_muka_tanggal': uangMukaTanggal,
            'uang_muka_jumlah': uangMukaJumlah,
            'tambahan_tanggal': tambahanTanggal,
            'tambahan_jumlah': tambahanJumlah,
            'kas_besar_tanggal': kasBesarTanggal,
            'kas_besar_jumlah': kasBesarJumlah,
            'keterangan_keuangan': keteranganKeuangan,
            'tanggal_masuk': tanggalMasuk,
            'uraian_singkat': uraianSingkat,
            'nomor_dokumen': nomorDokumen,
            'dokumen_dibutuhkan': dokumenDibutuhkan,
            'dokumen_diterima': dokumenDiterima,
            'status_pembayaran': statusPembayaran,
          })
          .select('id')
          .single();

      final documentId = inserted['id'];

      final incomeRows = incomeDetails
          .where((r) => (r['label'] as String? ?? '').trim().isNotEmpty)
          .map((r) => {
                'document_id': documentId,
                'label': r['label'],
                'amount': _cleanAmount(r['amount']),
              })
          .toList();

      if (incomeRows.isNotEmpty) {
        await _supabase.from('document_income_details').insert(incomeRows);
      }

      final expenseRows = expenses
          .where((r) => (r['proses'] as String? ?? '').trim().isNotEmpty)
          .map((r) => {
                'document_id': documentId,
                'proses': r['proses'],
                'tanggal': r['tanggal'],
                'amount': _cleanAmount(r['amount']),
              })
          .toList();

      if (expenseRows.isNotEmpty) {
        await _supabase.from('document_expenses').insert(expenseRows);
      }

      _view.hideLoading();
      _view.onSaveSuccess();
    } catch (e) {
      debugPrint('ERROR SAVE DOCUMENT: $e');
      _view.hideLoading();
      _view.onSaveError(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getDocumentTypes() async {
    try {
      final response = await _supabase.from('document_types').select().order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('ERROR DOCUMENT TYPES: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getStaffList() async {
    try {
      final response = await _supabase.from('staff').select('id, name').order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('ERROR STAFF LIST: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getClients() async {
    try {
      final response = await _supabase.from('clients').select('id, name').order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('ERROR CLIENT LIST: $e');
      return [];
    }
  }
}