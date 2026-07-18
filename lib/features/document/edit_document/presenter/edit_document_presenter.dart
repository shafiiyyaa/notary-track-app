import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../document_list/model/document_model.dart';
import '../../document_list/model/income_detail_model.dart';
import '../../document_list/model/expense_model.dart';
import '../view/edit_document_view.dart';

class EditDocPresenter {
  final EditDocumentViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  EditDocPresenter(this._view);

  // Helper untuk bersihkan titik dari string format Rupiah
  double _cleanAmount(dynamic value) {
    if (value == null) return 0;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString().replaceAll('.', '').replaceAll(',', '.')) ?? 0;
  }

  Future<void> fetchDocument(String documentId) async {
    _view.showLoading();

    try {
      final data = await _supabase
          .from('documents')
          .select('''
            *,
            document_types(name),
            staff(name),
            clients(name)
          ''')
          .eq('id', documentId)
          .single();

      final incomeData = await _supabase
          .from('document_income_details')
          .select()
          .eq('document_id', documentId);

      final expenseData = await _supabase
          .from('document_expenses')
          .select()
          .eq('document_id', documentId);

      final incomeDetails = List<Map<String, dynamic>>.from(incomeData)
          .map((m) => IncomeDetailModel.fromMap(m))
          .toList();

      final expenses = List<Map<String, dynamic>>.from(expenseData)
          .map((m) => ExpenseModel.fromMap(m))
          .toList();

      final document = DocumentModel.fromMap(
        data,
        incomeDetails: incomeDetails,
        expenses: expenses,
      );

      _view.hideLoading();
      _view.onDocumentLoaded(document);
    } catch (e) {
      debugPrint('ERROR FETCH DOCUMENT: $e');
      _view.hideLoading();
      _view.onError(e.toString());
    }
  }

  Future<void> updateDocument({
    required String id,
    required String clientId,
    required String phone,
    required int documentTypeId,
    required String kategori,
    required String staffId,
    required String deadline,
    required String status,
    required String notes,
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
    _view.showLoading();

    try {
      await _supabase.from('documents').update({
        'client_id': clientId,
        'phone': phone,
        'document_type_id': documentTypeId,
        'kategori': kategori,
        'staff_id': staffId,
        'deadline': deadline,
        'status': status,
        'notes': notes,
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
      }).eq('id', id);

      await _supabase.from('document_income_details').delete().eq('document_id', id);
      await _supabase.from('document_expenses').delete().eq('document_id', id);

      final incomeRows = incomeDetails
          .where((r) => (r['label'] as String? ?? '').trim().isNotEmpty)
          .map((r) => {
                'document_id': id,
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
                'document_id': id,
                'proses': r['proses'],
                'tanggal': r['tanggal'],
                'amount': _cleanAmount(r['amount']),
              })
          .toList();

      if (expenseRows.isNotEmpty) {
        await _supabase.from('document_expenses').insert(expenseRows);
      }

      _view.hideLoading();
      _view.onUpdateSuccess();
    } catch (e) {
      debugPrint('ERROR UPDATE DOCUMENT: $e');
      _view.hideLoading();
      _view.onError(e.toString());
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

  Future<List<Map<String, dynamic>>> getStaffs() async {
    try {
      final response =
          await _supabase.from('staff').select('id, name').order('name');
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