import 'package:supabase_flutter/supabase_flutter.dart';

import '../../document_list/model/document_model.dart';
import '../view/edit_document_view.dart';

class EditDocPresenter {
  final EditDocumentViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  EditDocPresenter(this._view);

  Future<void> fetchDocument(String documentId) async {
    _view.showLoading();

    try {
      final data = await _supabase
          .from('documents')
          .select('''
            *,
            document_types(name),
            profiles!staff_id(full_name)
          ''')
          .eq('id', documentId)
          .single();

      final document = DocumentModel.fromMap(data);

      _view.hideLoading();
      _view.onDocumentLoaded(document);
    } catch (e) {
      _view.hideLoading();
      _view.onError(e.toString());
    }
  }

  Future<void> updateDocument({
    required String id,
    required String clientName,
    required String phone,
    required int documentTypeId,
    required String deadline,
    required String status,
    required String notes,
    required double initialFee,
    required double additionalFee1,
    required double additionalFee2,
  }) async {
    _view.showLoading();

    try {
      final totalPrice =
          initialFee + additionalFee1 + additionalFee2;

      await _supabase
          .from('documents')
          .update({
            'client_name': clientName,
            'phone': phone,
            'document_type_id': documentTypeId,
            'deadline': deadline,
            'status': status,
            'notes': notes,
            'initial_fee': initialFee,
            'additional_fee_1': additionalFee1,
            'additional_fee_2': additionalFee2,
            'total_price': totalPrice,
          })
          .eq('id', id);

      _view.hideLoading();
      _view.onUpdateSuccess();
    } catch (e) {
      _view.hideLoading();
      _view.onError(e.toString());
    }
  }

  Future<List<Map<String, dynamic>>> getDocumentTypes() async {
    final response = await _supabase
        .from('document_types')
        .select()
        .order('name');

    return List<Map<String, dynamic>>.from(response);
  }
}