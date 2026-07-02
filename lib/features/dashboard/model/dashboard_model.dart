class DashboardSummary {
  final int totalDocuments;
  final int totalDeadlines;
  final int completedDocuments;

  DashboardSummary({required this.totalDocuments, required this.totalDeadlines, required this.completedDocuments});
}

class DeadlineItem {
  final String clientName;
  final String documentType;
  final DateTime deadline;
  final int remainingDays;

  DeadlineItem({
    required this.clientName,
    required this.documentType,
    required this.deadline,
    required this.remainingDays,
  });
}

