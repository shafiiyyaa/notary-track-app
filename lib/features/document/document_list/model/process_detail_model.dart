import 'package:intl/intl.dart';

class ProcessDetailModel {
  final int id;
  final int documentId;
  final String proses;
  final double amount;
  final String? tanggal;

  ProcessDetailModel({
    required this.id,
    required this.documentId,
    required this.proses,
    required this.amount,
    this.tanggal,
  });

  factory ProcessDetailModel.fromMap(Map<String, dynamic> map) {
    String? formattedDate;
    if (map['created_at'] != null) {
      try {
        final dt = DateTime.parse(map['created_at'].toString()).toLocal();
        formattedDate = DateFormat('dd MMM yyyy').format(dt);
      } catch (_) {
        formattedDate = map['created_at'].toString();
      }
    }

    return ProcessDetailModel(
      id: map['id'] as int? ?? 0,
      documentId: map['document_id'] as int? ?? 0,
      proses: map['proses'] as String? ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      tanggal: formattedDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'document_id': documentId,
      'proses': proses,
      'amount': amount,
    };
  }
}