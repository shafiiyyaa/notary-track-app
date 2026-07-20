import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../document_list/model/document_model.dart';
import '../../document_list/model/income_detail_model.dart';
import '../../document_list/model/expense_model.dart';
import '../view/detail_doc_view.dart';

class DetailDocPresenter {
  final DetailDocumentViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  DetailDocPresenter(this._view);

  Future<void> fetchDocumentDetail(String id) async {
    _view.showLoading();
    try {
      // TAMBAHKAN clients(name) DI SINI AGAR NAMA KLIEN MUNCUL
      final data = await _supabase
          .from('documents')
          .select('''
            *,
            clients(name),
            document_types(name),
            staff(name)
          ''')
          .eq('id', id)
          .single();

      final incomeData = await _supabase
          .from('document_income_details')
          .select()
          .eq('document_id', id);
      final expenseData = await _supabase
          .from('document_expenses')
          .select()
          .eq('document_id', id);

      final incomeDetails = List<Map<String, dynamic>>.from(
        incomeData,
      ).map((m) => IncomeDetailModel.fromMap(m)).toList();

      final expenses = List<Map<String, dynamic>>.from(
        expenseData,
      ).map((m) => ExpenseModel.fromMap(m)).toList();

      final doc = DocumentModel.fromMap(
        data,
        incomeDetails: incomeDetails,
        expenses: expenses,
      );

      final notes = data['notes'] ?? '';
      _view.hideLoading();
      _view.onDocumentLoaded(doc, notes);
    } catch (e) {
      debugPrint('ERROR FETCH DETAIL: $e');
      _view.hideLoading();
      _view.onDocumentError(e.toString());
    }
  }

  Future<void> deleteDocument(String id) async {
    _view.showLoading();
    try {
      await _supabase.from('documents').delete().eq('id', id);
      _view.hideLoading();
      _view.onDocumentDeleted();
    } catch (e) {
      _view.hideLoading();
      _view.onDocumentError('Gagal menghapus dokumen: ${e.toString()}');
    }
  }
}
