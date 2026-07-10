import '../model/dashboard_model.dart';

abstract class HomeViewContract {
  void onSummaryLoaded(DashboardSummary summary);
  void onPriorityLoaded(
    List<PriorityDeadlineItem> mendekati,
    List<PriorityDeadlineItem> terlambat,
    List<UnpaidItem> belumLunas,
  );
  void onSummaryError(String message);
}