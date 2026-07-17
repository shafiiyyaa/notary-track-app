import 'income_detail_model.dart';
import 'expense_model.dart';

class DocumentModel {
  final String id;

  final String clientId;
  final String clientName; // diambil dari join clients(name), read-only
  final String phone;

  final int documentTypeId;
  final String docType;

  final String kategori;

  final String staffId;
  final String staffName;

  final String dateIn;
  final String deadline;

  final String status;
  final String notes;

  final double kesepakatanBiaya;

  final String? uangMukaTanggal;
  final double uangMukaJumlah;
  final String? tambahanTanggal;
  final double tambahanJumlah;

  final String? kasBesarTanggal;
  final double kasBesarJumlah;

  final String keteranganKeuangan;

  final List<IncomeDetailModel> incomeDetails;
  final List<ExpenseModel> expenses;

  final String? tanggalMasuk;
  final String uraianSingkat;
  final String? nomorDokumen;
  // Field progressPercent dan tanggalSelesai dihapus sesuai request
  final String dokumenDibutuhkan;
  final String dokumenDiterima;
  final String statusPembayaran;

  DocumentModel({
    required this.id,
    required this.clientId,
    this.clientName = '',
    required this.phone,
    required this.documentTypeId,
    required this.docType,
    this.kategori = '',
    required this.staffId,
    required this.staffName,
    required this.dateIn,
    required this.deadline,
    required this.status,
    required this.notes,
    this.kesepakatanBiaya = 0,
    this.uangMukaTanggal,
    this.uangMukaJumlah = 0,
    this.tambahanTanggal,
    this.tambahanJumlah = 0,
    this.kasBesarTanggal,
    this.kasBesarJumlah = 0,
    this.keteranganKeuangan = '',
    this.incomeDetails = const [],
    this.expenses = const [],
    this.tanggalMasuk,
    this.uraianSingkat = '',
    this.nomorDokumen,
    this.dokumenDibutuhkan = '',
    this.dokumenDiterima = '',
    this.statusPembayaran = 'Belum Dibayar',
  });

  double get totalPemohon => uangMukaJumlah + tambahanJumlah;

  double get totalRincian =>
      incomeDetails.fold(0, (sum, item) => sum + item.amount);

  double get totalPengeluaran =>
      expenses.fold(0, (sum, item) => sum + item.amount);

  double get sisaKas => totalPemohon + kasBesarJumlah - totalPengeluaran;

  factory DocumentModel.fromMap(
    Map<String, dynamic> map, {
    List<IncomeDetailModel> incomeDetails = const [],
    List<ExpenseModel> expenses = const [],
  }) {
    return DocumentModel(
      id: map['id'].toString(),
      clientId: map['client_id']?.toString() ?? '',
      // Mengambil name dari objek clients hasil join Supabase
      clientName: map['clients'] != null ? (map['clients']['name'] ?? '') : '',
      phone: map['phone'] ?? '',
      documentTypeId: map['document_type_id'] is int 
          ? map['document_type_id'] 
          : int.tryParse(map['document_type_id']?.toString() ?? '0') ?? 0,
      // Mengambil name dari objek document_types hasil join Supabase
      docType: map['document_types'] != null ? (map['document_types']['name'] ?? '') : '',
      kategori: map['kategori'] ?? '',
      staffId: map['staff_id']?.toString() ?? '',
      // Mengambil name dari objek staff hasil join Supabase
      staffName: map['staff'] != null ? (map['staff']['name'] ?? '-') : '-',
      dateIn: map['created_at']?.toString().substring(0, 10) ?? '',
      deadline: map['deadline'] ?? '',
      status: map['status'] ?? 'Belum Diproses',
      notes: map['notes'] ?? '',
      kesepakatanBiaya: (map['kesepakatan_biaya'] as num?)?.toDouble() ?? 0,
      uangMukaTanggal: map['uang_muka_tanggal']?.toString(),
      uangMukaJumlah: (map['uang_muka_jumlah'] as num?)?.toDouble() ?? 0,
      tambahanTanggal: map['tambahan_tanggal']?.toString(),
      tambahanJumlah: (map['tambahan_jumlah'] as num?)?.toDouble() ?? 0,
      kasBesarTanggal: map['kas_besar_tanggal']?.toString(),
      kasBesarJumlah: (map['kas_besar_jumlah'] as num?)?.toDouble() ?? 0,
      keteranganKeuangan: map['keterangan_keuangan'] ?? '',
      incomeDetails: incomeDetails,
      expenses: expenses,
      tanggalMasuk: map['tanggal_masuk']?.toString(),
      uraianSingkat: map['uraian_singkat'] ?? '',
      nomorDokumen: map['nomor_dokumen']?.toString(),
      dokumenDibutuhkan: map['dokumen_dibutuhkan'] ?? '',
      dokumenDiterima: map['dokumen_diterima'] ?? '',
      statusPembayaran: map['status_pembayaran'] ?? 'Belum Dibayar',
    );
  }
}