class ExpenseModel {
  final String? id;
  final String proses;
  final String? tanggal;
  final double amount;

  ExpenseModel({
    this.id,
    required this.proses,
    this.tanggal,
    required this.amount,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) {
    return ExpenseModel(
      id: map['id']?.toString(),
      proses: map['proses'] ?? '',
      tanggal: map['tanggal']?.toString(),
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap(String documentId) {
    return {
      'document_id': documentId,
      'proses': proses,
      'tanggal': tanggal,
      'amount': amount,
    };
  }
}