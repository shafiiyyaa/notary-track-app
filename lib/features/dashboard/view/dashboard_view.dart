import '../model/dashboard_model.dart';

abstract class HomeViewContract {
  void onSummaryLoaded(DashboardSummary summary);

  void onDeadlineLoaded(List<DeadlineItem> deadlines);

  void onUserLoaded(String username);

  void onSummaryError(String message);
}
