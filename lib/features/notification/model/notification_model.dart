class NotificationModel {
  final int id;
  final String title;
  final String clientName;
  final String location;
  final String description;
  final DateTime scheduledDate;
  final int remainingDays;
  final bool isManual;

  NotificationModel({
    required this.id,
    required this.title,
    required this.clientName,
    this.location = '',
    required this.description,
    required this.scheduledDate,
    required this.remainingDays,
    required this.isManual,
  });
}