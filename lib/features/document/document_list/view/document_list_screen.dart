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

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedKategoriFilter;
  String? _selectedStatusFilter;

  final List<String> _kategoriList = ['Notaris', 'PPAT', 'Waarmerking', 'Legalisasi'];
  final List<String> _statusList = ['Belum Diproses', 'Diproses', 'Tertunda', 'Batal', 'Selesai'];

  @override
  void initState() {
    super.initState();
    _presenter = DocListPresenter(this);
    _presenter.fetchAllDocuments();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<DocumentModel> get _filteredList {
    return _documentList.where((doc) {
      final matchSearch = _searchQuery.isEmpty ||
          doc.clientName.toLowerCase().contains(_searchQuery) ||
          doc.docType.toLowerCase().contains(_searchQuery);
      final matchKategori = _selectedKategoriFilter == null || doc.kategori == _selectedKategoriFilter;
      final matchStatus = _selectedStatusFilter == null || doc.status == _selectedStatusFilter;
      return matchSearch && matchKategori && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredList;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Text(
                'Daftar Pekerjaan',
                style: GoogleFonts.comfortaa(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Cari nama klien / jenis dokumen...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 10),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedKategoriFilter,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      hint: const Text('Semua Kategori', style: TextStyle(fontSize: 13)),
                      items: _kategoriList
                          .map((k) => DropdownMenuItem<String>(value: k, child: Text(k, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedKategoriFilter = value),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _selectedStatusFilter,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                      ),
                      hint: const Text('Semua Status', style: TextStyle(fontSize: 13)),
                      items: _statusList
                          .map((s) => DropdownMenuItem<String>(value: s, child: Text(s, style: const TextStyle(fontSize: 13))))
                          .toList(),
                      onChanged: (value) => setState(() => _selectedStatusFilter = value),
                    ),
                  ),
                ],
              ),

              if (_selectedKategoriFilter != null || _selectedStatusFilter != null)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => setState(() {
                      _selectedKategoriFilter = null;
                      _selectedStatusFilter = null;
                    }),
                    child: const Text('Reset Filter', style: TextStyle(fontSize: 12)),
                  ),
                ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menampilkan ${filtered.length} dari ${_documentList.length} pekerjaan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              _documentList.isEmpty
                                  ? 'Belum ada dokumen'
                                  : 'Tidak ada pekerjaan yang cocok dengan filter',
                              textAlign: TextAlign.center,
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
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final doc = filtered[index];
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
                    'Dokumen: ${doc.docType}${doc.kategori.isNotEmpty ? ' (${doc.kategori})' : ''}',
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