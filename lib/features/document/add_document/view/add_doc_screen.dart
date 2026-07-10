import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notarytrackapp/shared/widgets/dynamic_list_field.dart';
import '../presenter/add_doc_presenter.dart';
import 'add_doc_view.dart';

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen>
    implements AddDocumentViewContract {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _noteController = TextEditingController();
  final _kesepakatanBiayaController = TextEditingController();

  final _uangMukaJumlahController = TextEditingController();
  final _tambahanJumlahController = TextEditingController();
  final _kasBesarJumlahController = TextEditingController();

  // --- Controller field baru ---
  final _tanggalMasukController = TextEditingController();
  final _uraianSingkatController = TextEditingController();
  final _nomorDokumenController = TextEditingController();
  final _progressPercentController = TextEditingController(text: '0');
  final _dokumenDibutuhkanController = TextEditingController();
  final _dokumenDiterimaController = TextEditingController();
  final _tanggalSelesaiController = TextEditingController();
  String _selectedStatusPembayaran = 'Belum Dibayar';
  final List<String> _statusPembayaranList = ['Belum Dibayar', 'DP', 'Lunas'];

  String? _uangMukaTanggal;
  String? _tambahanTanggal;
  String? _kasBesarTanggal;

  List<Map<String, dynamic>> _incomeDetailRows = [];
  List<Map<String, dynamic>> _expenseRows = [];

  List<Map<String, dynamic>> _documentTypes = [];
  int? _selectedDocumentTypeId;

  String? _selectedKategori;
  final List<String> _kategoriList = [
    'Notaris',
    'PPAT',
    'Waarmerking',
    'Legalisasi',
  ];

  List<Map<String, dynamic>> _staffList = [];
  String? _selectedStaffId;

  bool _isLoading = false;
  late AddDocPresenter _presenter;
  final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _presenter = AddDocPresenter(this);
    _loadDocumentTypes();
    _loadStaffList();

    // Default tanggal masuk = hari ini
    final now = DateTime.now();
    _tanggalMasukController.text =
        "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";
  }

  Future<void> _loadDocumentTypes() async {
    final data = await _presenter.getDocumentTypes();
    if (!mounted) return;
    setState(() {
      _documentTypes = data;
      if (data.isNotEmpty) _selectedDocumentTypeId = data.first['id'];
    });
  }

  Future<void> _loadStaffList() async {
    final data = await _presenter.getStaffList();
    if (!mounted) return;
    setState(() {
      _staffList = data;
      if (data.isNotEmpty) _selectedStaffId = data.first['id'];
    });
  }

  double _parseAmount(String text) =>
      double.tryParse(text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

  double get _uangMukaJumlah => _parseAmount(_uangMukaJumlahController.text);
  double get _tambahanJumlah => _parseAmount(_tambahanJumlahController.text);
  double get _kasBesarJumlah => _parseAmount(_kasBesarJumlahController.text);

  double get _totalPemohon => _uangMukaJumlah + _tambahanJumlah;

  double get _totalPengeluaran => _expenseRows.fold(
    0,
    (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0),
  );

  double get _sisaKas => _totalPemohon + _kasBesarJumlah - _totalPengeluaran;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _deadlineController.dispose();
    _noteController.dispose();
    _kesepakatanBiayaController.dispose();
    _uangMukaJumlahController.dispose();
    _tambahanJumlahController.dispose();
    _kasBesarJumlahController.dispose();
    _tanggalMasukController.dispose();
    _uraianSingkatController.dispose();
    _nomorDokumenController.dispose();
    _progressPercentController.dispose();
    _dokumenDibutuhkanController.dispose();
    _dokumenDiterimaController.dispose();
    _tanggalSelesaiController.dispose();
    super.dispose();
  }

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onSaveSuccess() => Navigator.pop(context, true);

  @override
  void onSaveError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _pickDate(void Function(String) onPicked) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onPicked(
        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    "Tambah Dokumen",
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              _buildLabel(context, 'Nama Klien'),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              // --- BARU: Tanggal Masuk ---
              _buildLabel(context, 'Tanggal Masuk'),
              _buildDateTile(
                context,
                _tanggalMasukController.text,
                (v) => setState(() => _tanggalMasukController.text = v),
              ),

              _buildLabel(context, 'Nomor Telepon'),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              _buildLabel(context, 'Kategori'),
              DropdownButtonFormField<String>(
                initialValue: _selectedKategori,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
                hint: const Text('Pilih kategori'),
                items: _kategoriList
                    .map(
                      (k) => DropdownMenuItem<String>(value: k, child: Text(k)),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedKategori = value),
              ),

              _buildLabel(context, 'Jenis Dokumen'),
              DropdownButtonFormField<int>(
                initialValue: _selectedDocumentTypeId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
                items: _documentTypes
                    .map(
                      (doc) => DropdownMenuItem<int>(
                        value: doc['id'],
                        child: Text(doc['name']),
                      ),
                    )
                    .toList(),
                onChanged: (value) =>
                    setState(() => _selectedDocumentTypeId = value),
              ),

              // --- BARU: Uraian Singkat & Nomor Dokumen ---
              _buildLabel(context, 'Uraian Singkat'),
              TextField(
                controller: _uraianSingkatController,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                  hintText: 'Uraian singkat pekerjaan',
                ),
              ),
              _buildLabel(context, 'Nomor Akta/Dokumen'),
              TextField(
                controller: _nomorDokumenController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                  hintText: 'Opsional',
                ),
              ),

              _buildLabel(context, "Staff Penanggung Jawab"),
              DropdownButtonFormField<String>(
                initialValue: _selectedStaffId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                  prefixIcon: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                items: _staffList
                    .map(
                      (staff) => DropdownMenuItem<String>(
                        value: staff['id'],
                        child: Text(staff['name']),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _selectedStaffId = value),
              ),

              // --- BARU: Progress (%) ---
              const SizedBox(height: 10),
              _buildLabel(context, 'Progress (%)'),
              TextField(
                controller: _progressPercentController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 10),
              _buildLabel(context, 'Deadline'),
              TextField(
                controller: _deadlineController,
                readOnly: true,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                  suffixIcon: const Icon(Icons.calendar_today),
                ),
                onTap: () => _pickDate(
                  (v) => setState(() => _deadlineController.text = v),
                ),
              ),

              // --- BARU: Tanggal Selesai ---
              _buildLabel(context, 'Tanggal Selesai (jika sudah selesai)'),
              _buildDateTile(
                context,
                _tanggalSelesaiController.text.isEmpty
                    ? null
                    : _tanggalSelesaiController.text,
                (v) => setState(() => _tanggalSelesaiController.text = v),
              ),

              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),

              // --- BARU: Dokumen Dibutuhkan & Diterima ---
              _buildLabel(context, 'Dokumen Dibutuhkan'),
              TextField(
                controller: _dokumenDibutuhkanController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),
              _buildLabel(context, 'Dokumen Diterima'),
              TextField(
                controller: _dokumenDiterimaController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),

              _buildLabel(context, 'Kesepakatan Biaya'),
              TextField(
                controller: _kesepakatanBiayaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                  hintText: 'Nominal kesepakatan awal dengan klien',
                ),
              ),

              // --- BARU: Status Pembayaran ---
              _buildLabel(context, 'Status Pembayaran'),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatusPembayaran,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
                items: _statusPembayaranList
                    .map(
                      (s) => DropdownMenuItem<String>(value: s, child: Text(s)),
                    )
                    .toList(),
                onChanged: (value) => setState(
                  () => _selectedStatusPembayaran = value ?? 'Belum Dibayar',
                ),
              ),

              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),

              Text(
                "Uang Masuk dari Pemohon",
                style: GoogleFonts.comfortaa(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 12),

              _buildLabel(context, 'Uang Muka - Tanggal'),
              _buildDateTile(
                context,
                _uangMukaTanggal,
                (v) => setState(() => _uangMukaTanggal = v),
              ),
              _buildLabel(context, 'Uang Muka - Jumlah'),
              TextField(
                controller: _uangMukaJumlahController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              _buildLabel(context, 'Tambahan - Tanggal'),
              _buildDateTile(
                context,
                _tambahanTanggal,
                (v) => setState(() => _tambahanTanggal = v),
              ),
              _buildLabel(context, 'Tambahan - Jumlah'),
              TextField(
                controller: _tambahanJumlahController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Uang Masuk Pemohon',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      _rupiah.format(_totalPemohon),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              DynamicListField(
                title: 'Rincian Uang Masuk',
                fields: [
                  DynamicFieldConfig(
                    key: 'label',
                    label: 'Catatan/Kendala',
                    type: DynamicFieldType.text,
                  ),
                  DynamicFieldConfig(
                    key: 'amount',
                    label: 'Jumlah',
                    type: DynamicFieldType.number,
                  ),
                ],
                onChanged: (rows) => _incomeDetailRows = rows,
              ),

              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),

              Text(
                "Uang Masuk dari Kas Besar",
                style: GoogleFonts.comfortaa(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 12),

              _buildLabel(context, 'Tanggal'),
              _buildDateTile(
                context,
                _kasBesarTanggal,
                (v) => setState(() => _kasBesarTanggal = v),
              ),
              _buildLabel(context, 'Jumlah'),
              TextField(
                controller: _kasBesarJumlahController,
                keyboardType: TextInputType.number,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),

              DynamicListField(
                title: 'Pengeluaran',
                fields: [
                  DynamicFieldConfig(
                    key: 'proses',
                    label: 'Proses',
                    type: DynamicFieldType.text,
                  ),
                  DynamicFieldConfig(
                    key: 'tanggal',
                    label: 'Tanggal',
                    type: DynamicFieldType.date,
                  ),
                  DynamicFieldConfig(
                    key: 'amount',
                    label: 'Jumlah',
                    type: DynamicFieldType.number,
                  ),
                ],
                onChanged: (rows) => setState(() => _expenseRows = rows),
              ),

              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),

              _buildLabel(context, 'Catatan/Kendala'),
              TextField(
                controller: _noteController,
                maxLines: 3,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _summaryRow(context, 'Total Masuk Pemohon', _totalPemohon),
                    _summaryRow(
                      context,
                      'Total Masuk Kas Besar',
                      _kasBesarJumlah,
                    ),
                    _summaryRow(
                      context,
                      'Total Pengeluaran',
                      _totalPengeluaran,
                    ),
                    const Divider(),
                    _summaryRow(context, 'Sisa Kas', _sisaKas, isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_selectedKategori == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Pilih kategori dulu'),
                              ),
                            );
                            return;
                          }
                          if (_selectedStaffId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Pilih staff penanggung jawab dulu',
                                ),
                              ),
                            );
                            return;
                          }

                          _presenter.saveDocument(
                            name: _nameController.text,
                            phone: _phoneController.text,
                            documentTypeId: _selectedDocumentTypeId!,
                            kategori: _selectedKategori!,
                            deadline: _deadlineController.text,
                            staffId: _selectedStaffId!,
                            note: _noteController.text,
                            kesepakatanBiaya: _parseAmount(
                              _kesepakatanBiayaController.text,
                            ),
                            uangMukaTanggal: _uangMukaTanggal,
                            uangMukaJumlah: _uangMukaJumlah,
                            tambahanTanggal: _tambahanTanggal,
                            tambahanJumlah: _tambahanJumlah,
                            kasBesarTanggal: _kasBesarTanggal,
                            kasBesarJumlah: _kasBesarJumlah,
                            keteranganKeuangan: _noteController.text,
                            incomeDetails: _incomeDetailRows,
                            expenses: _expenseRows,
                            // --- Field baru ---
                            tanggalMasuk: _tanggalMasukController.text.isEmpty
                                ? null
                                : _tanggalMasukController.text,
                            uraianSingkat: _uraianSingkatController.text,
                            nomorDokumen: _nomorDokumenController.text.isEmpty
                                ? null
                                : _nomorDokumenController.text,
                            progressPercent:
                                int.tryParse(_progressPercentController.text) ??
                                0,
                            dokumenDibutuhkan:
                                _dokumenDibutuhkanController.text,
                            dokumenDiterima: _dokumenDiterimaController.text,
                            tanggalSelesai:
                                _tanggalSelesaiController.text.isEmpty
                                ? null
                                : _tanggalSelesaiController.text,
                            statusPembayaran: _selectedStatusPembayaran,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Simpan Dokumen',
                          style: TextStyle(color: Colors.white),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTile(
    BuildContext context,
    String? value,
    void Function(String) onPicked,
  ) {
    return InkWell(
      onTap: () => _pickDate((v) => onPicked(v)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              value ?? 'Pilih tanggal',
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(
    BuildContext context,
    String label,
    double value, {
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            _rupiah.format(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isBold
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
    );
  }
}
