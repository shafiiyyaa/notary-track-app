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
    required double initialFee,
    required double additionalFee1,
    required double additionalFee2,
    required String note,
  }) async {
    if (name.isEmpty || deadline.isEmpty) {
      _view.onSaveError("Nama Klien dan Deadline wajib diisi!");
      return;
    }

    final totalPrice =
        initialFee + additionalFee1 + additionalFee2;

    _view.showLoading();

    try {
      await _supabase.from('documents').insert({
        'client_name': name,
        'phone': phone,
        'document_type_id': documentTypeId,
        'deadline': deadline,
        'notes': note,
        'status': 'Belum Diproses',
        'initial_fee': initialFee,
        'additional_fee_1': additionalFee1,
        'additional_fee_2': additionalFee2,
        'total_price': totalPrice,
      });

      _view.hideLoading();
      _view.onSaveSuccess();
    } catch (e) {
      _view.hideLoading();
      _view.onSaveError(e.toString());
    }
  }
}