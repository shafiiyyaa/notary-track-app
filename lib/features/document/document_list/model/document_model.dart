class DocumentModel {
  final String id;

  final String clientName;
  final String phone;

  final int documentTypeId;

  final String docType;

  final String staffId;
  final String staffName;

  final String dateIn;
  final String deadline;

  final String status;

  final String notes;

  final double initialFee;
  final double additionalFee1;
  final double additionalFee2;
  final double totalPrice;

  DocumentModel({
    required this.id,
    required this.clientName,
    required this.phone,
    required this.documentTypeId,
    required this.docType,
    required this.staffId,
    required this.staffName,
    required this.dateIn,
    required this.deadline,
    required this.status,
    required this.notes,
    required this.initialFee,
    required this.additionalFee1,
    required this.additionalFee2,
    required this.totalPrice,
  });

  factory DocumentModel.fromMap(Map<String, dynamic> map) {
    return DocumentModel(
      id: map['id'].toString(),

      clientName: map['client_name'] ?? '',

      phone: map['phone'] ?? '',

      documentTypeId: map['document_type_id'],

      docType: map['document_types']?['name'] ?? '',

      staffId: map['staff_id'] ?? '',
      staffName: map['staff']?['name'] ?? '-',

      dateIn: map['created_at']?.toString().substring(0, 10) ?? '',

      deadline: map['deadline'] ?? '',

      status: map['status'] ?? 'Belum Diproses',

      notes: map['notes'] ?? '',

      initialFee: (map['initial_fee'] as num?)?.toDouble() ?? 0,

      additionalFee1: (map['additional_fee_1'] as num?)?.toDouble() ?? 0,

      additionalFee2: (map['additional_fee_2'] as num?)?.toDouble() ?? 0,

      totalPrice: (map['total_price'] as num?)?.toDouble() ?? 0,
    );
  }
}