import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/constants.dart';
import '../model/document_model.dart';
import '../presenter/doc_list_presenter.dart';
import 'doc_list_view.dart';
import '../../detail_document/view/detail_doc_screen.dart';

class DocumentListScreen extends StatefulWidget {
  const DocumentListScreen({super.key});

  @override
  State<DocumentListScreen> createState() => _DocumentListScreenState();
}

class _DocumentListScreenState extends State<DocumentListScreen> implements DocumentListViewContract {
  late DocListPresenter _presenter;
  List<DocumentModel> _documentList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = DocListPresenter(this);
    _presenter.fetchAllDocuments();
  }
  
  @override
void onDocumentsLoaded(List<DocumentModel> documents) {
  print("Jumlah dokumen: ${documents.length}");

  setState(() {
    _documentList = documents;
  });
}

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onDocumentsError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text('Daftar Dokumen', style: GoogleFonts.comfortaa(fontSize: 24, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading 
                  ? const Center(child: CircularProgressIndicator())
                  : ListView.builder(
                      itemCount: _documentList.length,
                      itemBuilder: (context, index) {
                        final doc = _documentList[index];
                        return _buildDocCard(doc);
                      },
                    ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocCard(DocumentModel doc) {
    Color statusColor = AppColors.statusBelumProses;
    if (doc.status == 'Diproses') statusColor = AppColors.statusDiproses;
    if (doc.status == 'Selesai') statusColor = AppColors.statusSelesai;

    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => DetailDocumentScreen(documentId: doc.id))),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
        child: Row(
          children: [
            const CircleAvatar(backgroundColor: Color(0xFFEAEAEA), child: Icon(Icons.article_outlined, color: Colors.black54)),
            const SizedBox(width: 16),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Nama: ${doc.clientName}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Dokumen: ${doc.docType}'),
                Text('Deadline: ${doc.deadline}', style: const TextStyle(color: Colors.black54, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(color: statusColor, borderRadius: BorderRadius.circular(12)),
                  child: Text(doc.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                )
              ]),
            )
          ],
        ),
      ),
    );
  }
}