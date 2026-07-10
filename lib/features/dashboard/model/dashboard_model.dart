class DashboardSummary {
  final int totalDocuments;
  final int aktif;
  final int selesai;
  final int tertunda;
  final int batal;
  final int terlambat;

  final double totalNilaiJasa;
  final double totalLunas;
  final double totalBelumLunas;

  final double progressPercent;

  final Map<String, int> statusComposition;
  final Map<String, int> categoryComposition;

  DashboardSummary({
    required this.totalDocuments,
    required this.aktif,
    required this.selesai,
    required this.tertunda,
    required this.batal,
    required this.terlambat,
    required this.totalNilaiJasa,
    required this.totalLunas,
    required this.totalBelumLunas,
    required this.progressPercent,
    required this.statusComposition,
    required this.categoryComposition,
  });
}

class PriorityDeadlineItem {
  final String clientName;
  final String documentType;
  final DateTime deadline;
  final int remainingDays;

  PriorityDeadlineItem({
    required this.clientName,
    required this.documentType,
    required this.deadline,
    required this.remainingDays,
  });
}

class UnpaidItem {
  final String clientName;
  final String documentType;
  final double sisaTagihan;

  UnpaidItem({
    required this.clientName,
    required this.documentType,
    required this.sisaTagihan,
  });
}