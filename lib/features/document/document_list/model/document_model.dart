class DocumentModel {
  final String id;
  final String clientName;
  final String docType;
  final String dateIn;
  final String deadline;
  final String status;
  final double totalPrice;

  DocumentModel({required this.id, required this.clientName, required this.docType, required this.dateIn, required this.deadline, required this.status, required this.totalPrice});

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'].toString(),
      clientName: map['client_name'] ?? '',
      docType: map['doc_type'] ?? '',
      dateIn: map['date_in'] ?? '',
      deadline: map['deadline'] ?? '',
      status: map['status'] ?? 'Belum Diproses',
      totalPrice: (map['total_price'] ?? 0).toDouble(),
    );
  }
}