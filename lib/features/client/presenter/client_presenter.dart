import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/client_model.dart';
import '../view/client_view.dart';

class ClientPresenter {
  final ClientViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  ClientPresenter(this._view);

  /// Mengambil daftar semua klien + menghitung jumlah dokumen
  Future<void> fetchClients() async {
    _view.showLoading();
    try {
      // Ambil data clients
      final clientData = await _supabase
          .from('clients')
          .select()
          .order('name');

      final clientList = List<Map<String, dynamic>>.from(clientData);

      // Ambil hanya client_id (FIX error column client_name)
      final docData = await _supabase
          .from('documents')
          .select('client_id');

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
      _view.onError('Gagal memuat daftar klien');
    }
  }

  /// Membuat akun klien baru menggunakan Postgres Function
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
      final response = await _supabase.rpc(
        'create_client_account',
        params: {
          'p_name': name.trim(),
          'p_username': username.trim(),
          'p_password': password,
        },
      );

      _view.hideLoading();

      if (response is Map && response['success'] == true) {
        _view.onActionSuccess('Klien berhasil ditambahkan');
        fetchClients(); // refresh daftar
      } else {
        final errorMsg = response is Map && response['error'] != null 
            ? response['error'].toString() 
            : 'Gagal membuat klien';
        _view.onError(errorMsg);
      }
    } catch (e) {
      _view.hideLoading();
      debugPrint('CREATE CLIENT ERROR: $e');
      _view.onError('Terjadi kesalahan: ${e.toString()}');
    }
  }

  /// Menghapus klien
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
      
      final msg = e.toString().contains('foreign key') || 
                  e.toString().contains('violates')
          ? 'Klien ini masih dipakai di salah satu dokumen, tidak bisa dihapus.'
          : 'Gagal menghapus klien: ${e.toString()}';
      
      _view.onError(msg);
    }
  }
}