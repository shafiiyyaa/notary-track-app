class NotificationModel {
  final int id;
  final String clientName;
  final String documentType;
  final DateTime deadline;
  final int remainingDays;

  NotificationModel({
    required this.id,
    required this.clientName,
    required this.documentType,
    required this.deadline,
    required this.remainingDays,
  });
}