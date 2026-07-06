import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../view/register_view.dart';

class RegisterPresenter {
  final RegisterViewContract _view;
  final SupabaseClient _supabase = Supabase.instance.client;

  RegisterPresenter(this._view);

  Future<void> performRegister(
    String email,
    String password,
    String username,
  ) async {
    if (email.isEmpty || password.isEmpty || username.isEmpty) {
      _view.onRegisterError("Semua field wajib diisi!");
      return;
    }

    _view.showLoading();

    try {
      await _supabase.auth.signUp(
        email: email,
        password: password,
        data: {'username': username},
      );

      _view.hideLoading();
      _view.onRegisterSuccess();
    } catch (e) {
      debugPrint("ERROR REGISTER: $e");
      _view.hideLoading();
      _view.onRegisterError(e.toString());
    }
  }
}