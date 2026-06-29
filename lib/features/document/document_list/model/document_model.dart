class DocumentModel {
  final String id;
  final String clientName;
  final String docType;
  final String dateIn;
  final String deadline;
  final String status;
  final double totalPrice;

  DocumentModel({
    required this.id,
    required this.clientName,
    required this.docType,
    required this.dateIn,
    required this.deadline,
    required this.status,
    required this.totalPrice,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'].toString(),
      clientName: map['client_name'] ?? '',
      docType: map['document_types']?['name'] ?? '',
      dateIn: map['created_at']?.toString().substring(0, 10) ?? '',
      deadline: map['deadline'] ?? '',
      status: map['status'] ?? '',
      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
    );
  }
}
