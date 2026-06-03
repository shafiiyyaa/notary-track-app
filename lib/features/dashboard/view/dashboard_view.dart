import '../model/dashboard_model.dart';

abstract class HomeViewContract {
  void onSummaryLoaded(DashboardSummary summary);
  void onSummaryError(String message);
}