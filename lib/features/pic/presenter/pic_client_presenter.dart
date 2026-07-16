import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/pic_client_model.dart';
import '../view/pic_client_view.dart';

class PicClientPresenter {
  final PicClientViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  PicClientPresenter(this._view);

  // ================= STAFF / PIC =================

  Future<void> fetchStaffList() async {
    _view.showLoading();
    try {
      final staffData =
          await _supabase.from('staff').select('id, name').order('name');
      final staffList = List<Map<String, dynamic>>.from(staffData);

      final docData = await _supabase.from('documents').select('staff_id');
      final docs = List<Map<String, dynamic>>.from(docData);

      final counts = <String, int>{};
      for (final d in docs) {
        final sid = d['staff_id']?.toString();
        if (sid != null) counts[sid] = (counts[sid] ?? 0) + 1;
      }

      final result = staffList.map((s) {
        final id = s['id'].toString();
        return StaffModel(
          id: id,
          name: s['name'] ?? '',
          jobCount: counts[id] ?? 0,
        );
      }).toList();

      _view.hideLoading();
      _view.onStaffLoaded(result);
    } catch (e) {
      debugPrint('ERROR FETCH STAFF: $e');
      _view.hideLoading();
      _view.onError(e.toString());
    }
  }

  Future<void> addStaff(String name) async {
    if (name.trim().isEmpty) {
      _view.onError('Nama tidak boleh kosong');
      return;
    }
    _view.showLoading();
    try {
      await _supabase.from('staff').insert({'name': name.trim()});
      _view.hideLoading();
      _view.onActionSuccess('PIC berhasil ditambahkan');
      fetchStaffList();
    } catch (e) {
      debugPrint('ERROR ADD STAFF: $e');
      _view.hideLoading();
      _view.onError('Gagal menambah PIC: ${e.toString()}');
    }
  }

  Future<void> updateStaff(String id, String name) async {
    if (name.trim().isEmpty) {
      _view.onError('Nama tidak boleh kosong');
      return;
    }
    _view.showLoading();
    try {
      await _supabase.from('staff').update({'name': name.trim()}).eq('id', id);
      _view.hideLoading();
      _view.onActionSuccess('PIC berhasil diubah');
      fetchStaffList();
    } catch (e) {
      debugPrint('ERROR UPDATE STAFF: $e');
      _view.hideLoading();
      _view.onError('Gagal mengubah PIC: ${e.toString()}');
    }
  }

  Future<void> deleteStaff(String id) async {
    _view.showLoading();
    try {
      await _supabase.from('staff').delete().eq('id', id);
      _view.hideLoading();
      _view.onActionSuccess('PIC berhasil dihapus');
      fetchStaffList();
    } catch (e) {
      debugPrint('ERROR DELETE STAFF: $e');
      _view.hideLoading();
      final msg = e.toString().contains('foreign key') ||
              e.toString().contains('violates')
          ? 'PIC ini masih dipakai di salah satu dokumen, tidak bisa dihapus.'
          : 'Gagal menghapus PIC: ${e.toString()}';
      _view.onError(msg);
    }
  }

  // ================= KLIEN =================

  Future<void> fetchClients() async {
    _view.showLoading();
    try {
      // Ambil id, name, dan username
      final clientData = await _supabase
          .from('clients')
          .select('id, name, username')
          .order('name');
      final clientList = List<Map<String, dynamic>>.from(clientData);

      final docData = await _supabase.from('documents').select('client_id');
      final docs = List<Map<String, dynamic>>.from(docData);

      final counts = <String, int>{};
      for (final d in docs) {
        final cid = d['client_id']?.toString();
        if (cid != null) counts[cid] = (counts[cid] ?? 0) + 1;
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
    if (name.trim().isEmpty || username.trim().isEmpty) {
      _view.onError('Nama dan username tidak boleh kosong');
      return;
    }
    if (password.length < 6) {
      _view.onError('Password minimal 6 karakter');
      return;
    }
    _view.showLoading();
    try {
      await _supabase.from('clients').insert({
        'name': name.trim(),
        'username': username.trim(),
        'password': password,
      });
      _view.hideLoading();
      _view.onActionSuccess('Klien berhasil ditambahkan');
      fetchClients();
    } catch (e) {
      debugPrint('ERROR ADD CLIENT: $e');
      _view.hideLoading();
      _view.onError('Gagal menambah klien: ${e.toString()}');
    }
  }

  Future<void> deleteClient(String id) async {
    _view.showLoading();
    try {
      await _supabase.from('clients').delete().eq('id', id);
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