import 'package:supabase_flutter/supabase_flutter.dart';
import '../view/login_view.dart';

class LoginPresenter {
  final LoginViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  LoginPresenter(this._view);

  Future<void> performLogin(String email, String password) async {
    if (email.isEmpty || password.isEmpty) {
      _view.onLoginError("Email dan password tidak boleh kosong!");
      return;
    }

    _view.showLoading();
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );
      _view.hideLoading();
      if (response.user != null) {
        _view.onLoginSuccess();
      }
    } catch (e) {
      _view.hideLoading();
      _view.onLoginError(e.toString());
    }
  }
}