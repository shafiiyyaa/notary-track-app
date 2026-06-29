import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/document_model.dart';
import '../view/doc_list_view.dart';

class DocListPresenter {
  final DocumentListViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  DocListPresenter(this._view);

Future<void> fetchAllDocuments() async {
  _view.showLoading();

  try {
    final data = await _supabase
        .from('documents')
        .select();

    print("===== DOCUMENT LIST =====");
    print(data);

    final docs = (data as List)
        .map((e) => DocumentModel.fromMap(e))
        .toList();

    _view.hideLoading();
    _view.onDocumentsLoaded(docs);
  } catch (e) {
    print(e);
    _view.hideLoading();
    _view.onDocumentsError(e.toString());
  }
}
}