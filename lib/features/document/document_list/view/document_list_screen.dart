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

  // Filter yang sudah di-"apply" (dipakai buat filtering list).
  String? _selectedKategoriFilter;
  String? _selectedStatusFilter;
  int? _selectedBulanFilter; // 1-12
  String? _selectedTahunFilter;

  final List<String> _kategoriList = ['Notaris', 'PPAT', 'Waarmerking', 'Legalisasi'];
  final List<String> _statusList = ['Belum Diproses', 'Diproses', 'Tertunda', 'Batal', 'Selesai'];

  static const List<String> _bulanList = [
    'Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni',
    'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember',
  ];

  bool get _hasActiveFilter =>
      _selectedKategoriFilter != null ||
      _selectedStatusFilter != null ||
      _selectedBulanFilter != null ||
      _selectedTahunFilter != null;

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

  DateTime? _parseDeadline(String deadline) => DateTime.tryParse(deadline);

  // Tahun mulai dari 2026. Kalau butuh tahun lain, tinggal tambah manual di sini.
  static const List<String> _tahunOptions = [
    '2026',
    '2027',
    '2028',
  ];

  List<DocumentModel> get _filteredList {
    return _documentList.where((doc) {
      final matchSearch = _searchQuery.isEmpty ||
          doc.clientName.toLowerCase().contains(_searchQuery) ||
          doc.docType.toLowerCase().contains(_searchQuery);
      final matchKategori =
          _selectedKategoriFilter == null || doc.kategori == _selectedKategoriFilter;
      final matchStatus =
          _selectedStatusFilter == null || doc.status == _selectedStatusFilter;

      final date = _parseDeadline(doc.deadline);
      final matchBulan = _selectedBulanFilter == null ||
          (date != null && date.month == _selectedBulanFilter);
      final matchTahun = _selectedTahunFilter == null ||
          (date != null && date.year.toString() == _selectedTahunFilter);

      return matchSearch && matchKategori && matchStatus && matchBulan && matchTahun;
    }).toList();
  }

  Future<void> _openFilterSheet() async {
    // Nilai sementara di dalam sheet, baru di-commit ke state utama kalau user tekan "Filter".
    String? tempKategori = _selectedKategoriFilter;
    String? tempStatus = _selectedStatusFilter;
    int? tempBulan = _selectedBulanFilter;
    String? tempTahun = _selectedTahunFilter;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tampilkan daftar pekerjaan sesuai dengan kebutuhan anda.',
                    style: GoogleFonts.comfortaa(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildFilterDropdown<String>(
                    context: context,
                    hint: 'Semua Kategori',
                    value: tempKategori,
                    items: _kategoriList,
                    onChanged: (value) => setSheetState(() => tempKategori = value),
                  ),
                  const SizedBox(height: 12),

                  _buildFilterDropdown<String>(
                    context: context,
                    hint: 'Semua Status',
                    value: tempStatus,
                    items: _statusList,
                    onChanged: (value) => setSheetState(() => tempStatus = value),
                  ),
                  const SizedBox(height: 12),

                  _buildFilterDropdown<int>(
                    context: context,
                    hint: 'Semua Bulan',
                    value: tempBulan,
                    items: List.generate(12, (i) => i + 1),
                    itemLabelBuilder: (bulan) => _bulanList[bulan - 1],
                    onChanged: (value) => setSheetState(() => tempBulan = value),
                  ),
                  const SizedBox(height: 12),

                  _buildFilterDropdown<String>(
                    context: context,
                    hint: 'Semua Tahun',
                    value: tempTahun,
                    items: _tahunOptions,
                    onChanged: (value) => setSheetState(() => tempTahun = value),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _selectedKategoriFilter = tempKategori;
                              _selectedStatusFilter = tempStatus;
                              _selectedBulanFilter = tempBulan;
                              _selectedTahunFilter = tempTahun;
                            });
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Filter Pekerjaan'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Batal'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterDropdown<T>({
    required BuildContext context,
    required String hint,
    required T? value,
    required List<T> items,
    required ValueChanged<T?> onChanged,
    String Function(T)? itemLabelBuilder,
  }) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      hint: Text(hint, style: const TextStyle(fontSize: 13)),
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  itemLabelBuilder != null ? itemLabelBuilder(item) : item.toString(),
                  style: const TextStyle(fontSize: 13),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _resetFilter() {
    setState(() {
      _selectedKategoriFilter = null;
      _selectedStatusFilter = null;
      _selectedBulanFilter = null;
      _selectedTahunFilter = null;
    });
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

              Row(
                children: [
                  Expanded(
                    child: TextField(
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
                  ),
                  const SizedBox(width: 10),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _openFilterSheet,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Icon(
                              Icons.filter_list,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                      if (_hasActiveFilter)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              if (_hasActiveFilter)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetFilter,
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