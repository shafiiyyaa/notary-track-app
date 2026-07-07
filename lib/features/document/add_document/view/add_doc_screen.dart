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
  final _progressTerakhirController = TextEditingController();

  final _uangMukaJumlahController = TextEditingController();
  final _tambahanJumlahController = TextEditingController();
  final _kasBesarJumlahController = TextEditingController();

  String? _uangMukaTanggal;
  String? _tambahanTanggal;
  String? _kasBesarTanggal;

  List<Map<String, dynamic>> _incomeDetailRows = [];
  List<Map<String, dynamic>> _expenseRows = [];

  List<Map<String, dynamic>> _documentTypes = [];
  int? _selectedDocumentTypeId;

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
    _progressTerakhirController.dispose();
    _uangMukaJumlahController.dispose();
    _tambahanJumlahController.dispose();
    _kasBesarJumlahController.dispose();
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

              _buildLabel(context, 'Jenis Dokumen'),
              DropdownButtonFormField<int>(
                initialValue: _selectedDocumentTypeId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
                items: _documentTypes
                    .map((doc) => DropdownMenuItem<int>(
                          value: doc['id'],
                          child: Text(doc['name']),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedDocumentTypeId = value),
              ),

              _buildLabel(context, "Staff Penanggung Jawab"),
              DropdownButtonFormField<String>(
                initialValue: _selectedStaffId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                  prefixIcon: Icon(Icons.person, color: Theme.of(context).colorScheme.primary),
                ),
                items: _staffList
                    .map((staff) => DropdownMenuItem<String>(
                          value: staff['id'],
                          child: Text(staff['name']),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStaffId = value),
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
                onTap: () => _pickDate((v) => setState(() => _deadlineController.text = v)),
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
              _buildDateTile(context, _uangMukaTanggal,
                  (v) => setState(() => _uangMukaTanggal = v)),
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
              _buildDateTile(context, _tambahanTanggal,
                  (v) => setState(() => _tambahanTanggal = v)),
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
                    Text('Total Uang Masuk Pemohon',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).textTheme.bodyLarge?.color)),
                    Text(_rupiah.format(_totalPemohon),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary)),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              DynamicListField(
                title: 'Rincian Uang Masuk',
                fields: [
                  DynamicFieldConfig(key: 'label', label: 'Keterangan', type: DynamicFieldType.text),
                  DynamicFieldConfig(key: 'amount', label: 'Jumlah', type: DynamicFieldType.number),
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
              _buildDateTile(context, _kasBesarTanggal,
                  (v) => setState(() => _kasBesarTanggal = v)),
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
                  DynamicFieldConfig(key: 'proses', label: 'Proses', type: DynamicFieldType.text),
                  DynamicFieldConfig(key: 'tanggal', label: 'Tanggal', type: DynamicFieldType.date),
                  DynamicFieldConfig(key: 'amount', label: 'Jumlah', type: DynamicFieldType.number),
                ],
                onChanged: (rows) => setState(() => _expenseRows = rows),
              ),

              const SizedBox(height: 24),
              Divider(color: Theme.of(context).dividerColor),
              const SizedBox(height: 12),

              _buildLabel(context, 'Progress Dokumen Terakhir'),
              TextField(
                controller: _progressTerakhirController,
                maxLines: 2,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                  hintText: 'Contoh: menunggu tanda tangan klien',
                ),
              ),

              _buildLabel(context, 'Keterangan'),
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
                    _summaryRow(context, 'Total Masuk Kas Besar', _kasBesarJumlah),
                    _summaryRow(context, 'Total Pengeluaran', _totalPengeluaran),
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
                          if (_selectedStaffId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih staff penanggung jawab dulu')),
                            );
                            return;
                          }

                          _presenter.saveDocument(
                            name: _nameController.text,
                            phone: _phoneController.text,
                            documentTypeId: _selectedDocumentTypeId!,
                            deadline: _deadlineController.text,
                            staffId: _selectedStaffId!,
                            note: _noteController.text,
                            kesepakatanBiaya: _parseAmount(_kesepakatanBiayaController.text),
                            progressTerakhir: _progressTerakhirController.text,
                            uangMukaTanggal: _uangMukaTanggal,
                            uangMukaJumlah: _uangMukaJumlah,
                            tambahanTanggal: _tambahanTanggal,
                            tambahanJumlah: _tambahanJumlah,
                            kasBesarTanggal: _kasBesarTanggal,
                            kasBesarJumlah: _kasBesarJumlah,
                            keteranganKeuangan: _noteController.text,
                            incomeDetails: _incomeDetailRows,
                            expenses: _expenseRows,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Simpan Dokumen', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTile(BuildContext context, String? value, void Function(String) onPicked) {
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
              style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
            ),
            const Icon(Icons.calendar_today, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _summaryRow(BuildContext context, String label, double value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  color: Theme.of(context).textTheme.bodyLarge?.color)),
          Text(_rupiah.format(value),
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isBold
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).textTheme.bodyLarge?.color)),
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