import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../view/add_doc_view.dart';

class AddDocPresenter {
  final AddDocumentViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  AddDocPresenter(this._view);

  Future<void> saveDocument({
    required String name,
    required String phone,
    required int documentTypeId,
    required String deadline,
    required String staffId,
    required String note,
    String? uangMukaTanggal,
    required double uangMukaJumlah,
    String? tambahanTanggal,
    required double tambahanJumlah,
    String? kasBesarTanggal,
    required double kasBesarJumlah,
    required String keteranganKeuangan,
    required List<Map<String, dynamic>> incomeDetails,
    required List<Map<String, dynamic>> expenses,
  }) async {
    if (name.isEmpty || deadline.isEmpty) {
      _view.onSaveError("Nama Klien dan Deadline wajib diisi!");
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
            'client_name': name,
            'phone': phone,
            'document_type_id': documentTypeId,
            'deadline': deadline,
            'notes': note,
            'status': 'Belum Diproses',
            'staff_id': staffId,
            'uang_muka_tanggal': uangMukaTanggal,
            'uang_muka_jumlah': uangMukaJumlah,
            'tambahan_tanggal': tambahanTanggal,
            'tambahan_jumlah': tambahanJumlah,
            'kas_besar_tanggal': kasBesarTanggal,
            'kas_besar_jumlah': kasBesarJumlah,
            'keterangan_keuangan': keteranganKeuangan,
          })
          .select('id')
          .single();

      final documentId = inserted['id'];

      final incomeRows = incomeDetails
          .where((r) => (r['label'] as String? ?? '').trim().isNotEmpty)
          .map((r) => {
                'document_id': documentId,
                'label': r['label'],
                'amount': r['amount'],
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
                'amount': r['amount'],
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
      final response =
          await _supabase.from('document_types').select().order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('ERROR DOCUMENT TYPES: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getStaffList() async {
    try {
      final response =
          await _supabase.from('staff').select('id, name').order('name');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      debugPrint('ERROR STAFF LIST: $e');
      return [];
    }
  }
}