import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/client_model.dart';
import '../view/client_view.dart';

class ClientPresenter {
  final ClientViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  ClientPresenter(this._view);

  Future<void> fetchClients() async {
    _view.showLoading();
    try {
      final clientData = await _supabase.from('clients').select().order('name');
      final clientList = List<Map<String, dynamic>>.from(clientData);

      final docData = await _supabase.from('documents').select('client_id');
      final docs = List<Map<String, dynamic>>.from(docData);

      final counts = <String, int>{};
      for (final d in docs) {
        final cid = d['client_id']?.toString();
        if (cid != null) {
          counts[cid] = (counts[cid] ?? 0) + 1;
        }
      }

      final result = clientList.map((c) {
        final id = c['id'].toString();
        return ClientModel(
          id: id,
          name: c['name'] ?? '',
          username: c['username'] ?? '',
          jobCount: counts[id] ?? 0,
        );
      }).toList();

      _view.hideLoading();
      _view.onClientsLoaded(result);
    } catch (e) {
      debugPrint('ERROR FETCH CLIENTS: $e');
      _view.hideLoading();
      _view.onError(e.toString());
    }
  }

  Future<void> createClient({
    required String name,
    required String username,
    required String password,
  }) async {
    if (name.trim().isEmpty || username.trim().isEmpty || password.trim().isEmpty) {
      _view.onError('Nama, username, dan password wajib diisi');
      return;
    }
    if (password.length < 6) {
      _view.onError('Password minimal 6 karakter');
      return;
    }

    _view.showLoading();
    try {
      final response = await _supabase.functions.invoke(
        'create-client-account',
        body: {
          'name': name.trim(),
          'username': username.trim(),
          'password': password,
        },
      );

      _view.hideLoading();

      if (response.status != 200) {
        final data = response.data;
        final errMsg = (data is Map && data['error'] != null)
            ? data['error'].toString()
            : 'Gagal membuat akun klien';
        _view.onError(errMsg);
        return;
      }

      _view.onActionSuccess('Klien berhasil ditambahkan');
      fetchClients();
    } catch (e) {
      debugPrint('ERROR CREATE CLIENT: $e');
      _view.hideLoading();
      _view.onError('Gagal membuat akun klien: ${e.toString()}');
    }
  }

  Future<void> deleteClient(String clientId) async {
    _view.showLoading();
    try {
      await _supabase.from('clients').delete().eq('id', clientId);
      _view.hideLoading();
      _view.onActionSuccess('Klien berhasil dihapus');
      fetchClients();
    } catch (e) {
      debugPrint('ERROR DELETE CLIENT: $e');
      _view.hideLoading();
      final msg = e.toString().contains('foreign key') || e.toString().contains('violates')
          ? 'Klien ini masih dipakai di salah satu dokumen, tidak bisa dihapus.'
          : 'Gagal menghapus klien: ${e.toString()}';
      _view.onError(msg);
    }
  }
}