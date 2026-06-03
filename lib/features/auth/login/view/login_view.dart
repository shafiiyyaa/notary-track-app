abstract class LoginViewContract {
  void onLoginSuccess();
  void onLoginError(String message);
  void showLoading();
  void hideLoading();
}