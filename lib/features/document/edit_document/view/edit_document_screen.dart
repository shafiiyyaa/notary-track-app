import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:notarytrackapp/shared/widgets/dynamic_list_field.dart';
import '../../document_list/model/document_model.dart';
import '../presenter/edit_document_presenter.dart';
import 'edit_document_view.dart';

class EditDocumentScreen extends StatefulWidget {
  final DocumentModel document;

  const EditDocumentScreen({super.key, required this.document});

  @override
  State<EditDocumentScreen> createState() => _EditDocumentScreenState();
}

class _EditDocumentScreenState extends State<EditDocumentScreen>
    implements EditDocumentViewContract {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _noteController = TextEditingController();

  final _uangMukaJumlahController = TextEditingController();
  final _tambahanJumlahController = TextEditingController();
  final _kasBesarJumlahController = TextEditingController();

  String? _uangMukaTanggal;
  String? _tambahanTanggal;
  String? _kasBesarTanggal;

  List<Map<String, dynamic>> _incomeDetailRows = [];
  List<Map<String, dynamic>> _expenseRows = [];
  bool _financialLoaded = false;

  List<Map<String, dynamic>> _documentTypes = [];
  int? _selectedDocumentTypeId;

  bool _isLoading = false;
  List<Map<String, dynamic>> _staffs = [];
  String? _selectedStaffId;
  String? _selectedStatus;
  late EditDocPresenter _presenter;
  final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();

    _presenter = EditDocPresenter(this);

    _loadDocumentTypes();
    _loadStaffs();

    _presenter.fetchDocument(widget.document.id);

    final doc = widget.document;

    _nameController.text = doc.clientName;
    _phoneController.text = doc.phone;
    _deadlineController.text = doc.deadline;
    _noteController.text = doc.notes;
    _selectedStatus = doc.status;
  }

  Future<void> _loadDocumentTypes() async {
    final data = await _presenter.getDocumentTypes();
    if (!mounted) return;
    setState(() {
      _documentTypes = data;
      _selectedDocumentTypeId = widget.document.documentTypeId;
    });
  }

  Future<void> _loadStaffs() async {
    final data = await _presenter.getStaffs();
    if (!mounted) return;
    setState(() {
      _staffs = data;
      _selectedStaffId = widget.document.staffId;
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
  void onDocumentLoaded(DocumentModel document) {
    _nameController.text = document.clientName;
    _phoneController.text = document.phone;
    _deadlineController.text = document.deadline;
    _noteController.text = document.notes;

    _uangMukaTanggal = document.uangMukaTanggal;
    _uangMukaJumlahController.text =
        document.uangMukaJumlah == 0 ? '' : document.uangMukaJumlah.toStringAsFixed(0);

    _tambahanTanggal = document.tambahanTanggal;
    _tambahanJumlahController.text =
        document.tambahanJumlah == 0 ? '' : document.tambahanJumlah.toStringAsFixed(0);

    _kasBesarTanggal = document.kasBesarTanggal;
    _kasBesarJumlahController.text =
        document.kasBesarJumlah == 0 ? '' : document.kasBesarJumlah.toStringAsFixed(0);

    _incomeDetailRows = document.incomeDetails
        .map((e) => {'label': e.label, 'amount': e.amount})
        .toList();

    _expenseRows = document.expenses
        .map((e) => {'proses': e.proses, 'tanggal': e.tanggal, 'amount': e.amount})
        .toList();

    _selectedDocumentTypeId = document.documentTypeId;
    _selectedStaffId = document.staffId;
    _selectedStatus = document.status;
    _financialLoaded = true;

    setState(() {});
  }

  @override
  void onUpdateSuccess() => Navigator.pop(context, true);

  @override
  void onError(String message) {
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
                    "Edit Dokumen",
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
                ),
                items: _staffs
                    .map((staff) => DropdownMenuItem<String>(
                          value: staff['id'],
                          child: Text(staff['name']),
                        ))
                    .toList(),
                onChanged: (value) => setState(() => _selectedStaffId = value),
              ),

              const SizedBox(height: 10),
              _buildLabel(context, "Status"),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
                items: const [
                  DropdownMenuItem(value: "Belum Diproses", child: Text("Belum Diproses")),
                  DropdownMenuItem(value: "Diproses", child: Text("Diproses")),
                  DropdownMenuItem(value: "Selesai", child: Text("Selesai")),
                ],
                onChanged: (value) => setState(() => _selectedStatus = value),
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
              _buildDateTile(context, _uangMukaTanggal, (v) => setState(() => _uangMukaTanggal = v)),
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
              _buildDateTile(context, _tambahanTanggal, (v) => setState(() => _tambahanTanggal = v)),
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
              if (_financialLoaded)
                DynamicListField(
                  title: 'Rincian Uang Masuk',
                  fields: [
                    DynamicFieldConfig(key: 'label', label: 'Keterangan', type: DynamicFieldType.text),
                    DynamicFieldConfig(key: 'amount', label: 'Jumlah', type: DynamicFieldType.number),
                  ],
                  initialRows: _incomeDetailRows,
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
              _buildDateTile(context, _kasBesarTanggal, (v) => setState(() => _kasBesarTanggal = v)),
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

              if (_financialLoaded)
                DynamicListField(
                  title: 'Pengeluaran',
                  fields: [
                    DynamicFieldConfig(key: 'proses', label: 'Proses', type: DynamicFieldType.text),
                    DynamicFieldConfig(key: 'tanggal', label: 'Tanggal', type: DynamicFieldType.date),
                    DynamicFieldConfig(key: 'amount', label: 'Jumlah', type: DynamicFieldType.number),
                  ],
                  initialRows: _expenseRows,
                  onChanged: (rows) => setState(() => _expenseRows = rows),
                ),

              const SizedBox(height: 24),
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

              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_selectedDocumentTypeId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih jenis dokumen dulu')),
                            );
                            return;
                          }
                          if (_selectedStaffId == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih staff penanggung jawab dulu')),
                            );
                            return;
                          }
                          if (_selectedStatus == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Pilih status dulu')),
                            );
                            return;
                          }

                          _presenter.updateDocument(
                            id: widget.document.id,
                            clientName: _nameController.text,
                            phone: _phoneController.text,
                            documentTypeId: _selectedDocumentTypeId!,
                            staffId: _selectedStaffId!,
                            deadline: _deadlineController.text,
                            status: _selectedStatus!,
                            notes: _noteController.text,
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
                      : const Text("Update Dokumen", style: TextStyle(color: Colors.white)),
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
            Text(value ?? 'Pilih tanggal',
                style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color)),
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
        style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
      ),
    );
  }
}