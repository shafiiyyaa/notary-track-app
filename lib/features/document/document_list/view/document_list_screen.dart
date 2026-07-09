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
  State<DocumentListScreen> createState() => DocumentListScreenState();
}

class DocumentListScreenState extends State<DocumentListScreen>
    implements DocumentListViewContract {
  late DocListPresenter _presenter;
  List<DocumentModel> _documentList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = DocListPresenter(this);
    _presenter.fetchAllDocuments();
  }

  // Dipanggil dari luar (misal dari MainNavigation lewat GlobalKey)
  // untuk refresh data tanpa perlu keluar-masuk tab.
  void refreshDocuments() {
    _presenter.fetchAllDocuments();
  }

  @override
  void onDocumentsLoaded(List<DocumentModel> documents) {
    setState(() {
      _documentList = documents;
    });
  }

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onDocumentsError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                'Daftar Dokumen',
                style: GoogleFonts.comfortaa(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _documentList.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada dokumen',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.color
                                    ?.withOpacity(0.6),
                              ),
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _presenter.fetchAllDocuments(),
                            child: ListView.builder(
                              itemCount: _documentList.length,
                              itemBuilder: (context, index) {
                                final doc = _documentList[index];
                                return _buildDocCard(context, doc);
                              },
                            ),
                          ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDocCard(BuildContext context, DocumentModel doc) {
    Color statusColor = AppColors.statusBelumProses;
    if (doc.status == 'Diproses') statusColor = AppColors.statusDiproses;
    if (doc.status == 'Tertunda') statusColor = AppColors.statusTertunda;
    if (doc.status == 'Batal') statusColor = AppColors.statusBatal;
    if (doc.status == 'Selesai') statusColor = AppColors.statusSelesai;

    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailDocumentScreen(documentId: doc.id),
          ),
        );

        if (result == true) {
          _presenter.fetchAllDocuments();
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: Theme.of(context).dividerColor,
              child: Icon(
                Icons.article_outlined,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Nama: ${doc.clientName}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Dokumen: ${doc.docType}',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Deadline: ${doc.deadline}',
                    style: TextStyle(
                      color: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.color
                          ?.withOpacity(0.6),
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      doc.status,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}