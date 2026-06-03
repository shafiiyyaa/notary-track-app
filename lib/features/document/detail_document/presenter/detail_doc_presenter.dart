import 'package:supabase_flutter/supabase_flutter.dart';
import '../../document_list/model/document_model.dart';
import '../view/detail_doc_view.dart';

class DetailDocPresenter {
  final DetailDocumentViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  DetailDocPresenter(this._view);

  Future<void> fetchDocumentDetail(String id) async {
    _view.showLoading();
    try {
      final data = await _supabase.from('documents').select().eq('id', id).single();
      final doc = DocumentModel.fromMap(data);
      final notes = data['notes'] ?? '';
      _view.hideLoading();
      _view.onDocumentLoaded(doc, notes);
    } catch (e) {
      _view.hideLoading();
      _view.onDocumentError(e.toString());
    }
  }
}