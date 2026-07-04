import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notarytrackapp/constants/constants.dart';
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
  void onDocumentError(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _document == null)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
             Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.arrow_back),
                  splashRadius: 22,
                ),

                Text(
                  "Detail Dokumen",
                  style: GoogleFonts.comfortaa(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),
              Text(
                _document!.docType,
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 20),

              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildItem("Nama Klien", _document!.clientName),

                      _buildItem("Deadline", _document!.deadline),

                      _buildItem("Status", _document!.status),

                      _buildItem(
                        "Total Pembayaran",
                        "Rp ${_document!.totalPrice.toStringAsFixed(0)}",
                      ),

                      _buildItem("Catatan", _notes),
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
                ),
              ),

              const SizedBox(height: 15),

              _buildProgress(),

              const SizedBox(height: 30),

              SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit, color: Colors.white),
                  label: const Text(
                    "Edit Dokumen",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            EditDocumentScreen(document: _document!),
                      ),
                    );

                    _presenter.fetchDocumentDetail(widget.documentId);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),

          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  Widget _buildProgress() {
    int step = 0;

    if (_document!.status == "Diproses") {
      step = 1;
    }

    if (_document!.status == "Selesai") {
      step = 2;
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _circle("Belum", step >= 0),

        Expanded(
          child: Divider(
            thickness: 2,
            color: step >= 1 ? Colors.green : Colors.grey,
          ),
        ),

        _circle("Proses", step >= 1),

        Expanded(
          child: Divider(
            thickness: 2,
            color: step >= 2 ? Colors.green : Colors.grey,
          ),
        ),

        _circle("Selesai", step >= 2),
      ],
    );
  }

  Widget _circle(String title, bool active) {
    return Column(
      children: [
        CircleAvatar(
          radius: 18,
          backgroundColor: active ? Colors.green : Colors.grey.shade400,
          child: const Icon(Icons.check, color: Colors.white),
        ),

        const SizedBox(height: 5),

        Text(title),
      ],
    );
  }
}
