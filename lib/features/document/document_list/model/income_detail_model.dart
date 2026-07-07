class IncomeDetailModel {
  final String? id;
  final String label;
  final double amount;

  IncomeDetailModel({
    this.id,
    required this.label,
    required this.amount,
  });

  factory IncomeDetailModel.fromMap(Map<String, dynamic> map) {
    return IncomeDetailModel(
      id: map['id']?.toString(),
      label: map['label'] ?? '',
      amount: (map['amount'] as num?)?.toDouble() ?? 0,
    );
  }

  Map<String, dynamic> toMap(String documentId) {
    return {
      'document_id': documentId,
      'label': label,
      'amount': amount,
    };
  }
}