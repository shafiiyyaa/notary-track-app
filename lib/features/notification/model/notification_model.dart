class NotificationModel {
  final String clientName;
  final String documentType;
  final DateTime deadline;
  final int remainingDays;

  NotificationModel({
    required this.clientName,
    required this.documentType,
    required this.deadline,
    required this.remainingDays,
  });
}