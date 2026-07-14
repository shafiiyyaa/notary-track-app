import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../document_list/model/document_model.dart';
import '../presenter/detail_doc_presenter.dart';
import 'detail_doc_view.dart';
import '../../edit_document/view/edit_document_screen.dart';

class DetailDocumentScreen extends StatefulWidget {
  final String documentId;
  const DetailDocumentScreen({super.key, required this.documentId});

  @override
  State<DetailDocumentScreen> createState() => _DetailDocumentScreenState();
}

class _DetailDocumentScreenState extends State<DetailDocumentScreen>
    implements DetailDocumentViewContract {
  late DetailDocPresenter _presenter;
  DocumentModel? _document;
  String _notes = '';
  bool _isLoading = false;
  final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _presenter = DetailDocPresenter(this);
    _presenter.fetchDocumentDetail(widget.documentId);
  }

  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);
  @override
  void onDocumentLoaded(DocumentModel document, String notes) => setState(() {
        _document = document;
        _notes = notes;
      });
  @override
  void onDocumentError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void onDocumentDeleted() {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Dokumen berhasil dihapus')));
    Navigator.pop(context, true);
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Dokumen?'),
          content: Text(
            'Dokumen "${_document?.docType ?? ''}" untuk ${_document?.clientName ?? ''} akan dihapus permanen dan tidak bisa dikembalikan.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _presenter.deleteDocument(widget.documentId);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  /// Navigasi ke halaman Edit Dokumen, langsung ke step tertentu.
  /// step 0 = Identitas Klien, 1 = Dokumen, 2 = Keuangan.
  Future<void> _goToEdit(DocumentModel doc, {int step = 0}) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditDocumentScreen(document: doc, initialStep: step),
      ),
    );
    _presenter.fetchDocumentDetail(widget.documentId);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _document == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final doc = _document!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back)),
                  Text(
                    "Detail Dokumen",
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // ===== STATUS PROGRES DOKUMEN =====
              // Catatan: persentase keseluruhan TIDAK dihitung/ditampilkan di sini lagi.
              // Persentase itu adalah angka gabungan semua dokumen dan tempatnya di Dashboard,
              // dihitung dari bobot status tiap dokumen (Selesai=100%, Diproses=50%, Belum=0%),
              // lalu dirata-rata. Di halaman ini cukup ditampilkan status dokumen ini saja.
              Text(
                "Progress Dokumen",
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 15),
              _buildProgress(context, doc),
              const SizedBox(height: 30),
              // ===== END STATUS PROGRES DOKUMEN =====

              // ===== DATA KLIEN =====
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Data Klien",
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _goToEdit(doc, step: 0),
                    icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Card(
                elevation: 2,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildItem(context, "Nama Klien", doc.clientName),
                      _buildItem(context, "Jenis Dokumen", doc.docType),
                      _buildItem(context, "Kategori", doc.kategori.isEmpty ? '-' : doc.kategori),
                      _buildItem(context, "Tanggal Masuk", doc.tanggalMasuk ?? '-'),
                      _buildItem(context, "Deadline", doc.deadline),
                      _buildItem(context, "Tanggal Selesai", doc.tanggalSelesai ?? '-'),
                      _buildItem(context, "Status", doc.status),
                      _buildItem(context, "Staff", doc.staffName),
                      _buildItem(context, "Uraian Singkat",
                          doc.uraianSingkat.isEmpty ? '-' : doc.uraianSingkat),
                      _buildItem(context, "Nomor Akta/Dokumen", doc.nomorDokumen ?? '-'),
                      _buildItem(
                        context,
                        "Kesepakatan Biaya",
                        doc.kesepakatanBiaya == 0
                            ? '-'
                            : _rupiah.format(doc.kesepakatanBiaya),
                      ),
                      _buildItem(context, "Status Pembayaran", doc.statusPembayaran),
                      _buildItem(context, "Catatan/Kendala", _notes),
                    ],
                  ),
                ),
              ),
              // ===== END DATA KLIEN =====

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Data Dokumen",
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _goToEdit(doc, step: 1),
                    icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Card(
                elevation: 2,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Dokumen Dibutuhkan",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(height: 4),
                      Text(
                        doc.dokumenDibutuhkan.isEmpty ? '-' : doc.dokumenDibutuhkan,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                      const SizedBox(height: 16),
                      Text("Dokumen Diterima",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(height: 4),
                      Text(
                        doc.dokumenDiterima.isEmpty ? '-' : doc.dokumenDiterima,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Rincian Keuangan",
                    style: GoogleFonts.comfortaa(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  IconButton(
                    onPressed: () => _goToEdit(doc, step: 2),
                    icon: Icon(Icons.edit, color: Theme.of(context).colorScheme.primary),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              Card(
                elevation: 2,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Uang Masuk dari Pemohon",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(height: 6),
                      _buildItem(context, "Uang Muka",
                          "${doc.uangMukaTanggal ?? '-'} • ${_rupiah.format(doc.uangMukaJumlah)}"),
                      _buildItem(context, "Tambahan",
                          "${doc.tambahanTanggal ?? '-'} • ${_rupiah.format(doc.tambahanJumlah)}"),
                      _summaryRow(context, "Total Pemohon", doc.totalPemohon, isBold: true),

                      if (doc.incomeDetails.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        Text("Rincian Uang Masuk",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(height: 6),
                        ...doc.incomeDetails.map(
                          (item) => _buildItem(context, item.label, _rupiah.format(item.amount)),
                        ),
                      ],

                      const Divider(height: 32),
                      Text("Uang Masuk dari Kas Besar",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).textTheme.bodyLarge?.color)),
                      const SizedBox(height: 6),
                      _buildItem(context, "Tanggal", doc.kasBesarTanggal ?? '-'),
                      _summaryRow(context, "Jumlah Kas Besar", doc.kasBesarJumlah, isBold: true),

                      if (doc.expenses.isNotEmpty) ...[
                        const Divider(height: 32),
                        Text("Pengeluaran",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.bodyLarge?.color)),
                        const SizedBox(height: 6),
                        ...doc.expenses.map(
                          (item) => _buildItem(
                            context,
                            item.proses,
                            "${item.tanggal ?? '-'} • ${_rupiah.format(item.amount)}",
                          ),
                        ),
                        _summaryRow(context, "Total Pengeluaran", doc.totalPengeluaran, isBold: true),
                      ],

                      const Divider(height: 32),
                      _summaryRow(context, "Sisa Kas", doc.sisaKas, isBold: true, highlight: true),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  label: const Text("Hapus Dokumen",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _confirmDelete,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(title,
                style: TextStyle(
                    fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          ),
          Expanded(
            child: Text(value, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, double value,
      {bool isBold = false, bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
          Text(
            _rupiah.format(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: highlight ? 18 : 14,
              color: highlight ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  // ================= STATUS PROGRES (bukan persentase, hanya penanda tahap) =================
  Widget _buildProgress(BuildContext context, DocumentModel doc) {
    final primary = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(context).dividerColor;

    int step = 0;
    if (doc.status == "Diproses") step = 1;
    if (doc.status == "Selesai") step = 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _circle(context, "Belum", step >= 0, primary, inactiveColor),
        Expanded(
          child: Divider(
            thickness: 2,
            color: step >= 1 ? primary : inactiveColor,
          ),
        ),
        _circle(context, "Proses", step >= 1, primary, inactiveColor),
        Expanded(
          child: Divider(
            thickness: 2,
            color: step >= 2 ? primary : inactiveColor,
          ),
        ),
        _circle(context, "Selesai", step >= 2, primary, inactiveColor),
      ],
    );
  }

  Widget _circle(
    BuildContext context,
    String title,
    bool active,
    Color primary,
    Color inactiveColor,
  ) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: active ? primary : Theme.of(context).cardColor,
            border: Border.all(
              color: active ? primary : inactiveColor,
              width: 2,
            ),
          ),
          alignment: Alignment.center,
          child: Icon(
            Icons.check,
            size: 18,
            color: active ? Colors.white : inactiveColor,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          title,
          style: TextStyle(
            color: active ? primary : Theme.of(context).textTheme.bodySmall?.color,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }
}