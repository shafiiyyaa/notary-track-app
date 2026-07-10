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
              const SizedBox(height: 24),

              Text(
                doc.docType,
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 20),

              Card(
                elevation: 2,
                color: Theme.of(context).cardColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildItem(context, "Kategori", doc.kategori.isEmpty ? '-' : doc.kategori),
                      _buildItem(context, "Nama Klien", doc.clientName),
                      _buildItem(context, "Deadline", doc.deadline),
                      _buildItem(context, "Status", doc.status),
                      _buildItem(context, "Staff", doc.staffName),
                      _buildItem(
                        context,
                        "Kesepakatan Biaya",
                        doc.kesepakatanBiaya == 0
                            ? '-'
                            : _rupiah.format(doc.kesepakatanBiaya),
                      ),
                      _buildItem(context, "Catatan", _notes),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),
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

              if (doc.progressTerakhir.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Progress Dokumen Terakhir",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        doc.progressTerakhir,
                        style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 30),
              Text(
                "Rincian Keuangan",
                style: GoogleFonts.comfortaa(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 15),

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
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text("Edit Dokumen",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => EditDocumentScreen(document: doc)),
                    );
                    _presenter.fetchDocumentDetail(widget.documentId);
                  },
                ),
              ),

              const SizedBox(height: 12),
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

  Widget _buildProgress(BuildContext context, DocumentModel doc) {
    int step = 0;
    if (doc.status == "Diproses") step = 1;
    if (doc.status == "Selesai") step = 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _circle(context, "Belum", step >= 0),
        Expanded(
            child: Divider(thickness: 2, color: step >= 1 ? Colors.green : Theme.of(context).dividerColor)),
        _circle(context, "Proses", step >= 1),
        Expanded(
            child: Divider(thickness: 2, color: step >= 2 ? Colors.green : Theme.of(context).dividerColor)),
        _circle(context, "Selesai", step >= 2),
      ],
    );
  }

  Widget _circle(BuildContext context, String title, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: active ? Colors.green : Colors.grey.shade400,
          child: const Icon(Icons.check, color: Colors.white),
        ),
        const SizedBox(height: 5),
        Text(title, style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
      ],
    );
  }
}