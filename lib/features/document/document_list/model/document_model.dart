import 'income_detail_model.dart';
import 'expense_model.dart';

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

  // Uang Masuk dari Pemohon
  final String? uangMukaTanggal;
  final double uangMukaJumlah;
  final String? tambahanTanggal;
  final double tambahanJumlah;

  // Uang Masuk dari Kas Besar
  final String? kasBesarTanggal;
  final double kasBesarJumlah;

  final String keteranganKeuangan;

  // List dinamis
  final List<IncomeDetailModel> incomeDetails;
  final List<ExpenseModel> expenses;

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
    this.uangMukaTanggal,
    this.uangMukaJumlah = 0,
    this.tambahanTanggal,
    this.tambahanJumlah = 0,
    this.kasBesarTanggal,
    this.kasBesarJumlah = 0,
    this.keteranganKeuangan = '',
    this.incomeDetails = const [],
    this.expenses = const [],
  });

  // Total Uang Masuk dari Pemohon (Uang Muka + Tambahan)
  double get totalPemohon => uangMukaJumlah + tambahanJumlah;

  // Total Rincian Uang Masuk (dari list dinamis)
  double get totalRincian =>
      incomeDetails.fold(0, (sum, item) => sum + item.amount);

  // Total Pengeluaran (dari list dinamis)
  double get totalPengeluaran =>
      expenses.fold(0, (sum, item) => sum + item.amount);

  // Sisa Kas = Total Pemohon + Kas Besar - Total Pengeluaran
  double get sisaKas => totalPemohon + kasBesarJumlah - totalPengeluaran;

  factory DocumentModel.fromMap(
    Map<String, dynamic> map, {
    List<IncomeDetailModel> incomeDetails = const [],
    List<ExpenseModel> expenses = const [],
  }) {
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
      uangMukaTanggal: map['uang_muka_tanggal']?.toString(),
      uangMukaJumlah: (map['uang_muka_jumlah'] as num?)?.toDouble() ?? 0,
      tambahanTanggal: map['tambahan_tanggal']?.toString(),
      tambahanJumlah: (map['tambahan_jumlah'] as num?)?.toDouble() ?? 0,
      kasBesarTanggal: map['kas_besar_tanggal']?.toString(),
      kasBesarJumlah: (map['kas_besar_jumlah'] as num?)?.toDouble() ?? 0,
      keteranganKeuangan: map['keterangan_keuangan'] ?? '',
      incomeDetails: incomeDetails,
      expenses: expenses,
    );
  }
}