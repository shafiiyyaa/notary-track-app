import 'package:supabase_flutter/supabase_flutter.dart';
import '../view/add_doc_view.dart';

class AddDocPresenter {
  final AddDocumentViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  AddDocPresenter(this._view);

  Future<void> saveDocument({required String name, required String type, required String deadline, required double price, required String note}) async {
    if (name.isEmpty || deadline.isEmpty) {
      _view.onSaveError("Nama dan Deadline wajib diisi!");
      return;
    }

    _view.showLoading();
    try {
      await _supabase.from('documents').insert({
        'client_name': name,
        'doc_type': type,
        'date_in': DateTime.now().toIso8601String().substring(0, 10),
        'deadline': deadline,
        'total_price': price,
        'notes': note,
        'status': 'Belum Diproses'
      });
      _view.hideLoading();
      _view.onSaveSuccess();
    } catch (e) {
      _view.hideLoading();
      _view.onSaveError(e.toString());
    }
  }
}