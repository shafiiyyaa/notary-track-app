import '../model/dashboard_model.dart';

abstract class HomeViewContract {
  void onUserLoaded(String username);
  void onSummaryLoaded(DashboardSummary summary);
  void onDeadlineLoaded(List<DeadlineItem> deadlines);
  void onSummaryError(String message);
}