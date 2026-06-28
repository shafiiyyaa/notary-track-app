class HistoryModel {
  final int id;
  final String status;
 final String staff;
  final String waktu;
  final String doc;

  HistoryModel({
    required this.id,
    required this.status,
    required this.staff,
    required this.waktu,
    required this.doc,
  });

  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    return HistoryModel(
      id: json['id'],
      status: json['status'] ?? '',
      staff: json['profiles']?['username'] ?? '-',
      waktu: json['deadline'] ?? '',
      doc: json['document_types']?['name'] ?? '-',
    );
  }
}