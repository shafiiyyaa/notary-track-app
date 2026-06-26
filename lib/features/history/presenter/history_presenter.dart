import 'package:supabase_flutter/supabase_flutter.dart';

import '../model/history_model.dart';
import '../view/history_view.dart';

class HistoryPresenter {
  final HistoryViewContract _view;

  final SupabaseClient _supabase = Supabase.instance.client;

  HistoryPresenter(this._view);

  Future<void> loadHistory() async {
    _view.showLoading();

    try {
      final response = await _supabase
          .from('documents')
          .select('''
            id,
            status,
            deadline,
            profiles(name),
            document_types(name)
          ''')
          .order('deadline');

      final list = response
          .map<HistoryModel>((e) => HistoryModel.fromJson(e))
          .toList();

      _view.displayHistory(list);
    } catch (e) {
      _view.showError(e.toString());
    }

    _view.hideLoading();
  }
}