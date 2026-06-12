class NotificationModel {
  final String title;
  final String deadline;
  final String date;
  final bool isUrgent;

  NotificationModel({
    required this.title,
    required this.deadline,
    required this.date,
    required this.isUrgent,
  });
}