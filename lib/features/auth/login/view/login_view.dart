abstract class LoginViewContract {
  void onLoginSuccess(String role); // Tambahin parameter role
  void onLoginError(String message);
  void showLoading();
  void hideLoading();
}