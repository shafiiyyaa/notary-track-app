import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../view/login_view.dart';

class LoginPresenter {
  final LoginViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  LoginPresenter(this._view);

  Future<void> performLogin({
    required String role,
    required String identifier, // Bisa email atau username
    required String password,
  }) async {
    if (identifier.isEmpty || password.isEmpty) {
      _view.onLoginError("Email/Username dan password tidak boleh kosong!");
      return;
    }

    _view.showLoading();
    try {
      if (role == 'Staff') {
        // ---- LOGIN STAFF (PAKAI SUPABASE AUTH) ----
        final response = await _supabase.auth.signInWithPassword(
          email: identifier,
          password: password,
        );
        
        _view.hideLoading();
        if (response.user != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_role', 'Staff');
          _view.onLoginSuccess('Staff');
        }
      } else {
        // ---- LOGIN KLIEN (PAKAI TABEL CLIENTS) ----
        final response = await _supabase
            .from('clients')
            .select('id, name')
            .eq('username', identifier)
            .eq('password', password)
            .maybeSingle();

        _view.hideLoading();
        if (response != null) {
          final userId = response['id'].toString();
          final userName = response['name'] ?? 'Klien';

          // Simpan sesi klien di SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('user_id', userId);
          await prefs.setString('user_name', userName);
          await prefs.setString('user_role', 'Klien');
          
          _view.onLoginSuccess('Klien');
        } else {
          _view.onLoginError("Username atau password klien salah!");
        }
      }
    } catch (e) {
      _view.hideLoading();
      _view.onLoginError(e.toString());
    }
  }
}