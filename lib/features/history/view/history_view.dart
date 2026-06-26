import '../model/history_model.dart';

abstract class HistoryViewContract {
  void displayHistory(List<HistoryModel> list);

  void showLoading();

  void hideLoading();

  void showError(String message);
}