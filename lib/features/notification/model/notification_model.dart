class NotificationModel {
  final int id;
  final String title;       // Judul notif (cth: "Deadline Hari Ini" atau "Janji Temu")
  final String clientName;
  final DateTime scheduledDate;
  final int remainingDays;
  final bool isManual;      // Untuk membedakan notif manual vs deadline dokumen

  NotificationModel({
    required this.id,
    required this.title,
    required this.clientName,
    required this.scheduledDate,
    required this.remainingDays,
    this.isManual = false,
  });
}