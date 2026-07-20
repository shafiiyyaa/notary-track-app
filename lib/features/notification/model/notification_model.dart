class NotificationModel {
  final int id;
  final String title;
  final String clientName;
  final String description; // TAMBAHAN: Untuk menyimpan deskripsi/catatan
  final DateTime scheduledDate;
  final int remainingDays;
  final bool isManual;

  NotificationModel({
    required this.id,
    required this.title,
    required this.clientName,
    this.description = '', // Default kosong
    required this.scheduledDate,
    required this.remainingDays,
    this.isManual = false,
  });
}