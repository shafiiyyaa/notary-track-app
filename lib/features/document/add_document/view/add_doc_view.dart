abstract class AddDocumentViewContract {
  void onSaveSuccess();
  void onSaveError(String message);
  void showLoading();
  void hideLoading();
}