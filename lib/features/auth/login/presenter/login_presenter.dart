import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../view/login_view.dart';

class LoginPresenter {
  final LoginViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  LoginPresenter(this._view);

  Future<void> performLogin({
    required String role,
    required String identifier,
    required String password,
  }) async {
    if (identifier.isEmpty || password.isEmpty) {
      _view.onLoginError("Username dan password tidak boleh kosong!");
      return;
    }

    _view.showLoading();
    try {
      String tableName = role == 'Staff' ? 'staff' : 'clients';

      final response = await _supabase
          .from(tableName)
          .select('id, name')
          .eq('username', identifier)
          .eq('password', password)
          .maybeSingle();

      _view.hideLoading();
      
      if (response != null) {
        final userId = response['id'].toString();
        final userName = response['name'] ?? 'User';

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_id', userId);
        await prefs.setString('user_name', userName);
        await prefs.setString('user_role', role);
        
        _view.onLoginSuccess(role);
      } else {
        _view.onLoginError("Username atau password salah!");
      }
    } catch (e) {
      _view.hideLoading();
      _view.onLoginError(e.toString());
    }
  }
}