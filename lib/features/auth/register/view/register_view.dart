abstract class RegisterViewContract {
  void onRegisterSuccess();
  void onRegisterError(String message);
  void showLoading();
  void hideLoading();
}