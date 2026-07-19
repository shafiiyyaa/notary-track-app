abstract class LoginViewContract {
  void onLoginSuccess(String role);
  void onLoginError(String message);
  void showLoading();
  void hideLoading();
}