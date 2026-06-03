import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../document_list/model/document_model.dart';
import '../presenter/detail_doc_presenter.dart';
import 'detail_doc_view.dart';

class DetailDocumentScreen extends StatefulWidget {
  final String documentId;
  const DetailDocumentScreen({super.key, required this.documentId});

  @override
  State<DetailDocumentScreen> createState() => _DetailDocumentScreenState();
}

class _DetailDocumentScreenState extends State<DetailDocumentScreen> implements DetailDocumentViewContract {
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
  void onDocumentLoaded(DocumentModel document, String notes) => setState(() { _document = document; _notes = notes; });
  @override
  void onDocumentError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    if (_isLoading || _document == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(_document!.docType, style: GoogleFonts.comfortaa(fontSize: 26, fontWeight: FontWeight.bold)),
          Text('Klien: ${_document!.clientName}', style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 20),
          const Text('Catatan:', style: TextStyle(fontWeight: FontWeight.bold)),
          Text(_notes),
          const Divider(height: 40),
          Text('Status Progres: ${_document!.status}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Text('Total Pembayaran: RP. ${_document!.totalPrice.toStringAsFixed(2)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}