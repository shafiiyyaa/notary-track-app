import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/staff_model.dart';
import '../view/pic_view.dart';

class PicPresenter {
  final PicViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  PicPresenter(this._view);

  Future<void> fetchStaffList() async {
    _view.showLoading();
    try {
      final staffData = await _supabase.from('staff').select('id, name').order('name');
      final staffList = List<Map<String, dynamic>>.from(staffData);

      // Hitung jumlah dokumen per staff (buat info "X pekerjaan")
      final docData = await _supabase.from('documents').select('staff_id');
      final docs = List<Map<String, dynamic>>.from(docData);

      final counts = <String, int>{};
      for (final d in docs) {
        final sid = d['staff_id']?.toString();
        if (sid != null) {
          counts[sid] = (counts[sid] ?? 0) + 1;
        }
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
      final msg = e.toString().contains('foreign key') || e.toString().contains('violates')
          ? 'PIC ini masih dipakai di salah satu dokumen, tidak bisa dihapus.'
          : 'Gagal menghapus PIC: ${e.toString()}';
      _view.onError(msg);
    }
  }
}