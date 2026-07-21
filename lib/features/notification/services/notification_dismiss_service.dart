import 'package:shared_preferences/shared_preferences.dart';

/// Menyimpan daftar notifikasi yang sudah "ditandai selesai/dibaca"
/// oleh user, supaya tidak muncul lagi di list notifikasi.
class NotificationDismissService {
  static const String _prefsKey = 'dismissed_notifications';

  /// Membuat key unik. Perlu prefix karena id dokumen dan id manual
  /// bisa saja sama angkanya tapi beda sumber data.
  static String buildKey({required int id, required bool isManual}) {
    return isManual ? 'manual_$id' : 'doc_$id';
  }

  Future<Set<String>> getDismissedKeys() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_prefsKey)?.toSet() ?? <String>{};
  }

  Future<void> dismiss({required int id, required bool isManual}) async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getStringList(_prefsKey) ?? <String>[];
    final key = buildKey(id: id, isManual: isManual);
    if (!current.contains(key)) {
      current.add(key);
      await prefs.setStringList(_prefsKey, current);
    }
  }

  /// Opsional: kalau suatu saat mau reset semua yang pernah di-dismiss.
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}