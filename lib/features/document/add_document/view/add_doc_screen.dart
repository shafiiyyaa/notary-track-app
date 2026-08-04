import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../presenter/add_doc_presenter.dart';
import '../view/add_doc_view.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat.decimalPattern('id_ID');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    String rawText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    rawText = rawText.replaceAll(RegExp(r'^0+'), '');
    if (rawText.isEmpty) {
      return TextEditingValue(
        text: '0',
        selection: TextSelection.collapsed(offset: 1),
      );
    }
    final int? value = int.tryParse(rawText);
    if (value == null) return oldValue;
    String newText = _formatter.format(value);
    return TextEditingValue(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length),
    );
  }
}

class RequiredDoc {
  String name;
  bool isReceived;
  RequiredDoc(this.name, {this.isReceived = false});
}

class AddDocumentScreen extends StatefulWidget {
  const AddDocumentScreen({super.key});

  @override
  State<AddDocumentScreen> createState() => _AddDocumentScreenState();
}

class _AddDocumentScreenState extends State<AddDocumentScreen>
    implements AddDocumentViewContract {
  final _phoneController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _noteController = TextEditingController();
  final _kesepakatanBiayaController = TextEditingController();
  final _uangMukaJumlahController = TextEditingController();
  final _tanggalMasukController = TextEditingController();
  final _uraianSingkatController = TextEditingController();
  final _nomorDokumenController = TextEditingController();
  final _newDocController = TextEditingController();

  String? _uangMukaTanggal;
  DateTime? _deadlineDateTime;

  List<Map<String, dynamic>> _incomeDetailRows = [];
  List<Map<String, dynamic>> _expenseRows = [];
  final List<RequiredDoc> _requiredDocs = [];

  List<Map<String, dynamic>> _documentTypes = [];
  int? _selectedDocumentTypeId;

  String? _selectedKategori;
  final List<String> _kategoriList = ['Notaris', 'PPAT', 'Waarmerking', 'Legalisasi'];

  List<Map<String, dynamic>> _staffList = [];
  String? _selectedStaffId;

  List<Map<String, dynamic>> _clientList = [];
  String? _selectedClientId;

  bool _isLoading = false;
  late AddDocPresenter _presenter;
  final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  final _pageController = PageController();
  int _currentStep = 0;
  final List<String> _stepTitles = ['Identitas Klien', 'Dokumen', 'Keuangan'];

  @override
  void initState() {
    super.initState();
    _presenter = AddDocPresenter(this);
    _loadDocumentTypes();
    _loadStaffList();
    _loadClientList();

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

  Future<void> _loadClientList() async {
    final data = await _presenter.getClients();
    if (!mounted) return;
    setState(() {
      _clientList = data;
    });
  }

  double _parseAmount(String text) =>
      double.tryParse(text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;

  double get _uangMukaJumlah => _parseAmount(_uangMukaJumlahController.text);

  double get _totalIncomeDetails => _incomeDetailRows.fold(
        0,
        (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0),
      );

  double get _totalPemohon => _uangMukaJumlah + _totalIncomeDetails;

  double get _totalPengeluaran => _expenseRows.fold(
        0,
        (sum, r) => sum + ((r['amount'] as num?)?.toDouble() ?? 0),
      );

  bool get _hasFinanceData => _uangMukaJumlah > 0 || _totalIncomeDetails > 0;

  bool get _isLunas {
    final kesepakatan = _parseAmount(_kesepakatanBiayaController.text);
    return kesepakatan > 0 && _totalPemohon >= kesepakatan;
  }

  bool get _hasDocReceived => _requiredDocs.any((doc) => doc.isReceived);

  bool get _isAllDocsReceived {
    if (_requiredDocs.isEmpty) return true;
    return _requiredDocs.every((doc) => doc.isReceived);
  }

  String get _autoStatus {
    if (!_hasFinanceData && !_hasDocReceived) return 'Belum Diproses';
    if (_isAllDocsReceived && _isLunas) return 'Selesai';
    return 'Diproses';
  }

  String get _autoStatusPembayaran {
    final kesepakatan = _parseAmount(_kesepakatanBiayaController.text);
    if (kesepakatan == 0 || _totalPemohon == 0) {
      return 'Belum Dibayar';
    } else if (_totalPemohon >= kesepakatan) {
      return 'Lunas';
    } else {
      return 'DP';
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _phoneController.dispose();
    _deadlineController.dispose();
    _noteController.dispose();
    _kesepakatanBiayaController.dispose();
    _uangMukaJumlahController.dispose();
    _tanggalMasukController.dispose();
    _uraianSingkatController.dispose();
    _nomorDokumenController.dispose();
    _newDocController.dispose();
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

  Future<void> _pickDeadlineDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _deadlineDateTime ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (pickedDate == null) return;
    if (!mounted) return;

    final pickedTime = await showTimePicker(
      context: context,
      initialTime: _deadlineDateTime != null
          ? TimeOfDay.fromDateTime(_deadlineDateTime!)
          : const TimeOfDay(hour: 8, minute: 0),
    );
    if (pickedTime == null) return;

    final combined = DateTime(
      pickedDate.year,
      pickedDate.month,
      pickedDate.day,
      pickedTime.hour,
      pickedTime.minute,
    );

    setState(() {
      _deadlineDateTime = combined;
      _deadlineController.text = DateFormat('dd MMMM yyyy, HH:mm', 'id_ID').format(combined);
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  bool _validateStep(int step) {
    if (step == 0) {
      if (_selectedClientId == null) {
        _showSnack('Pilih klien dulu');
        return false;
      }
      if (_phoneController.text.length < 10 || _phoneController.text.length > 13) {
        _showSnack('Nomor telepon harus terdiri dari 10-13 digit');
        return false;
      }
      return true;
    }
    if (step == 1) {
      if (_selectedKategori == null) {
        _showSnack('Pilih kategori dulu');
        return false;
      }
      if (_selectedDocumentTypeId == null) {
        _showSnack('Pilih jenis dokumen dulu');
        return false;
      }
      if (_selectedStaffId == null) {
        _showSnack('Pilih staff penanggung jawab dulu');
        return false;
      }
      if (_deadlineDateTime == null) {
        _showSnack('Pilih tanggal & jam deadline dulu');
        return false;
      }
      return true;
    }
    return true;
  }

  void _nextStep() {
    if (!_validateStep(_currentStep)) return;
    if (_currentStep < _stepTitles.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _prevStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _submit() {
    if (!_validateStep(0) || !_validateStep(1)) return;

    String dokumenDibutuhkan = _requiredDocs.map((d) => d.name).join('\n');
    String dokumenDiterima = _requiredDocs.where((d) => d.isReceived).map((d) => d.name).join('\n');

    _presenter.saveDocument(
      clientId: _selectedClientId!,
      phone: _phoneController.text,
      documentTypeId: _selectedDocumentTypeId!,
      kategori: _selectedKategori!,
      deadline: _deadlineDateTime!.toIso8601String(),
      staffId: _selectedStaffId!,
      note: _noteController.text,
      kesepakatanBiaya: _parseAmount(_kesepakatanBiayaController.text),
      uangMukaTanggal: _uangMukaTanggal,
      uangMukaJumlah: _uangMukaJumlah,
      keteranganKeuangan: _noteController.text,
      incomeDetails: _incomeDetailRows,
      expenses: _expenseRows,
      tanggalMasuk: _tanggalMasukController.text.isEmpty ? null : _tanggalMasukController.text,
      uraianSingkat: _uraianSingkatController.text,
      nomorDokumen: _nomorDokumenController.text.isEmpty ? null : _nomorDokumenController.text,
      dokumenDibutuhkan: dokumenDibutuhkan,
      dokumenDiterima: dokumenDiterima,
      statusPembayaran: _autoStatusPembayaran,
      status: _autoStatus,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: _isLoading ? null : _prevStep,
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    "Tambah Dokumen",
                    style: GoogleFonts.comfortaa(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
              child: _buildStepIndicator(),
            ),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (i) => setState(() => _currentStep = i),
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    child: _buildStepIdentitas(),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    child: _buildStepDokumen(),
                  ),
                  SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
                    child: _buildStepKeuangan(),
                  ),
                ],
              ),
            ),
            _buildBottomBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicator() {
    final primary = Theme.of(context).colorScheme.primary;
    final inactiveColor = Theme.of(context).dividerColor;

    return Row(
      children: List.generate(_stepTitles.length * 2 - 1, (i) {
        if (i.isEven) {
          final stepIndex = i ~/ 2;
          final isActive = stepIndex <= _currentStep;
          final isDone = stepIndex < _currentStep;
          return Column(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isActive ? primary : Theme.of(context).cardColor,
                  border: Border.all(color: isActive ? primary : inactiveColor, width: 2),
                ),
                alignment: Alignment.center,
                child: isDone
                    ? const Icon(Icons.check, size: 18, color: Colors.white)
                    : Text(
                        '${stepIndex + 1}',
                        style: TextStyle(
                          color: isActive ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 6),
              SizedBox(
                width: 84,
                child: Text(
                  _stepTitles[stepIndex],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: stepIndex == _currentStep ? FontWeight.bold : FontWeight.normal,
                    color: isActive ? primary : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ),
            ],
          );
        } else {
          final lineStepIndex = i ~/ 2;
          final isActive = lineStepIndex < _currentStep;
          return Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 20),
              height: 2,
              color: isActive ? primary : inactiveColor,
            ),
          );
        }
      }),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: _isLoading ? null : _prevStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  side: BorderSide(color: Theme.of(context).colorScheme.primary),
                ),
                child: Text('Kembali', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : (_currentStep < _stepTitles.length - 1 ? _nextStep : _submit),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : Text(
                      _currentStep < _stepTitles.length - 1 ? 'Lanjut' : 'Simpan Dokumen',
                      style: const TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIdentitas() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, 'Klien'),
        DropdownButtonFormField<String>(
          initialValue: _selectedClientId,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: InputBorder.none,
          ),
          hint: const Text('Pilih klien'),
          items: _clientList
              .map((c) => DropdownMenuItem<String>(
                    value: c['id'].toString(),
                    child: Text(c['name'] ?? ''),
                  ))
              .toList(),
          onChanged: (value) => setState(() => _selectedClientId = value),
        ),
        _buildLabel(context, 'Tanggal Masuk'),
        _buildDateTile(context, _tanggalMasukController.text, (v) => setState(() => _tanggalMasukController.text = v)),
        _buildLabel(context, 'Nomor Telepon'),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(13),
          ],
          onChanged: (val) => setState(() {}),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: InputBorder.none,
            hintText: '10-13 digit nomor telepon',
            errorText: (_phoneController.text.isNotEmpty && _phoneController.text.length < 10)
                ? 'Nomor telepon minimal 10 digit'
                : null,
          ),
        ),
      ],
    );
  }

  Widget _buildStepDokumen() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, 'Kategori'),
        DropdownButtonFormField<String>(
          initialValue: _selectedKategori,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: InputBorder.none,
          ),
          hint: const Text('Pilih kategori'),
          items: _kategoriList.map((k) => DropdownMenuItem<String>(value: k, child: Text(k))).toList(),
          onChanged: (value) => setState(() => _selectedKategori = value),
        ),
        _buildLabel(context, 'Jenis Dokumen'),
        DropdownButtonFormField<int>(
          initialValue: _selectedDocumentTypeId,
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: InputBorder.none,
          ),
          items: _documentTypes
              .map((doc) => DropdownMenuItem<int>(value: doc['id'], child: Text(doc['name'])))
              .toList(),
          onChanged: (value) => setState(() => _selectedDocumentTypeId = value),
        ),
        _buildLabel(context, 'Uraian Singkat'),
        TextField(
          controller: _uraianSingkatController,
          maxLines: 2,
          onChanged: (_) => setState(() {}),
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
          isExpanded: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: InputBorder.none,
          ),
          items: _staffList
              .map((staff) => DropdownMenuItem<String>(value: staff['id'], child: Text(staff['name'])))
              .toList(),
          onChanged: (value) => setState(() => _selectedStaffId = value),
        ),
        const SizedBox(height: 10),
        _buildLabel(context, "Status"),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status otomatis: $_autoStatus',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
              Icon(Icons.auto_awesome, size: 16, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Status dihitung otomatis berdasarkan data dokumen & keuangan yang sudah diisi.',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
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
            hintText: 'Pilih tanggal & jam deadline',
            suffixIcon: const Icon(Icons.event),
          ),
          onTap: _pickDeadlineDateTime,
        ),
        const SizedBox(height: 16),
        Divider(color: Theme.of(context).dividerColor),
        const SizedBox(height: 8),
        _buildLabel(context, 'Dokumen Dibutuhkan & Diterima'),
        Text(
          'Tambahkan dokumen yang dibutuhkan, lalu centang jika sudah diterima.',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _newDocController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                  hintText: 'Masukkan nama dokumen...',
                ),
                onSubmitted: (val) {
                  if (val.trim().isNotEmpty) {
                    setState(() {
                      _requiredDocs.add(RequiredDoc(val.trim()));
                      _newDocController.clear();
                    });
                  }
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
              onPressed: () {
                if (_newDocController.text.trim().isNotEmpty) {
                  setState(() {
                    _requiredDocs.add(RequiredDoc(_newDocController.text.trim()));
                    _newDocController.clear();
                  });
                }
              },
            ),
          ],
        ),
        const SizedBox(height: 12),
        _requiredDocs.isEmpty
            ? Text('Belum ada dokumen dibutuhkan.', style: TextStyle(fontSize: 12, color: Colors.grey))
            : Column(
                children: _requiredDocs.map((doc) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: doc.isReceived ? Theme.of(context).colorScheme.primary : Colors.transparent,
                        width: 1.5,
                      ),
                    ),
                    child: Row(
                      children: [
                        Checkbox(
                          value: doc.isReceived,
                          onChanged: (val) => setState(() => doc.isReceived = val ?? false),
                          activeColor: Theme.of(context).colorScheme.primary,
                        ),
                        Expanded(
                          child: Text(
                            doc.name,
                            style: TextStyle(
                              decoration: doc.isReceived ? TextDecoration.lineThrough : TextDecoration.none,
                              color: doc.isReceived ? Colors.grey : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, size: 18, color: Colors.red),
                          onPressed: () => setState(() => _requiredDocs.remove(doc)),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }

  Widget _buildStepKeuangan() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(context, 'Kesepakatan Biaya'),
        TextField(
          controller: _kesepakatanBiayaController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          onChanged: (_) => setState(() {}),
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: InputBorder.none,
            hintText: 'Nominal kesepakatan awal dengan klien',
          ),
        ),
        _buildLabel(context, 'Status Pembayaran'),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Status otomatis: $_autoStatusPembayaran',
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
              Icon(Icons.monetization_on_outlined, size: 16, color: Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Status pembayaran dihitung otomatis berdasarkan total uang masuk pemohon vs kesepakatan biaya.',
          style: TextStyle(
            fontSize: 11,
            color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(height: 20),
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
        _buildLabel(context, 'Uang Muka - Nominal Pembayaran'),
        TextField(
          controller: _uangMukaJumlahController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
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
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
              ),
              Text(
                _rupiah.format(_totalPemohon),
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Divider(color: Theme.of(context).dividerColor),
        const SizedBox(height: 12),
        Text(
          "Pembayaran Tambahan",
          style: GoogleFonts.comfortaa(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _incomeDetailRows.length,
          itemBuilder: (context, index) {
            return _DynamicFinanceRow(
              index: index,
              data: _incomeDetailRows[index],
              isExpense: false,
              onChanged: (newData) {
                setState(() {
                  _incomeDetailRows[index] = newData;
                });
              },
              onRemove: () {
                setState(() {
                  _incomeDetailRows.removeAt(index);
                });
              },
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _incomeDetailRows.add({'tanggal': null, 'label': '', 'amount': 0});
              });
            },
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            label: Text('Tambah Pembayaran', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
        ),
        const SizedBox(height: 24),
        Divider(color: Theme.of(context).dividerColor),
        const SizedBox(height: 12),
        Text(
          "Pengeluaran Operasional",
          style: GoogleFonts.comfortaa(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 12),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _expenseRows.length,
          itemBuilder: (context, index) {
            return _DynamicFinanceRow(
              index: index,
              data: _expenseRows[index],
              isExpense: true,
              onChanged: (newData) {
                setState(() {
                  _expenseRows[index] = newData;
                });
              },
              onRemove: () {
                setState(() {
                  _expenseRows.removeAt(index);
                });
              },
            );
          },
        ),
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: () {
              setState(() {
                _expenseRows.add({'tanggal': null, 'proses': '', 'amount': 0});
              });
            },
            icon: Icon(Icons.add, color: Theme.of(context).colorScheme.primary),
            label: Text('Tambah Pengeluaran', style: TextStyle(color: Theme.of(context).colorScheme.primary)),
          ),
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
              _summaryRow(context, 'Kesepakatan Biaya', _parseAmount(_kesepakatanBiayaController.text), isBold: true),
              _summaryRow(context, 'Total Dibayar Pemohon', _totalPemohon, isBold: true),
              _summaryRow(context, 'Total Pengeluaran', _totalPengeluaran, isBold: true),
              const Divider(),
              _summaryRow(context, 'Kurang Bayar', _parseAmount(_kesepakatanBiayaController.text) - _totalPemohon, isBold: true),
            ],
          ),
        ),
      ],
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
          Text(
            label,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          Text(
            _rupiah.format(value < 0 ? 0 : value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isBold ? Theme.of(context).colorScheme.primary : Theme.of(context).textTheme.bodyLarge?.color,
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

// ================= CUSTOM WIDGET UNTUK FORM DINAMIS =================
class _DynamicFinanceRow extends StatefulWidget {
  final int index;
  final Map<String, dynamic> data;
  final Function(Map<String, dynamic>) onChanged;
  final bool isExpense;
  final VoidCallback onRemove;

  const _DynamicFinanceRow({
    required this.index,
    required this.data,
    required this.onChanged,
    required this.isExpense,
    required this.onRemove,
  });

  @override
  State<_DynamicFinanceRow> createState() => _DynamicFinanceRowState();
}

class _DynamicFinanceRowState extends State<_DynamicFinanceRow> {
  late TextEditingController _descController;
  late TextEditingController _amountController;
  String? _date;

  @override
  void initState() {
    super.initState();
    _descController = TextEditingController(
      text: widget.isExpense ? (widget.data['proses'] ?? '') : (widget.data['label'] ?? ''),
    );
    
    final amount = widget.data['amount'];
    if (amount != null && amount != 0) {
      _amountController = TextEditingController(
        text: NumberFormat.decimalPattern('id_ID').format(amount),
      );
    } else {
      _amountController = TextEditingController(text: '');
    }
    
    _date = widget.data['tanggal'];
  }

  void _updateData() {
    final data = Map<String, dynamic>.from(widget.data);
    if (widget.isExpense) {
      data['proses'] = _descController.text;
    } else {
      data['label'] = _descController.text;
    }
    data['tanggal'] = _date;
    data['amount'] = double.tryParse(_amountController.text.replaceAll('.', '').replaceAll(',', '.')) ?? 0;
    widget.onChanged(data);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _date = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
        _updateData();
      });
    }
  }

  @override
  void dispose() {
    _descController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              widget.isExpense ? 'Pengeluaran ${widget.index + 1}' : 'Pembayaran ${widget.index + 1}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.black54),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
              onPressed: widget.onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            )
          ],
        ),
        const SizedBox(height: 8),
        // Tanggal
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Tanggal',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        InkWell(
          onTap: _pickDate,
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
                  _date ?? 'Pilih tanggal',
                  style: TextStyle(color: Theme.of(context).textTheme.bodyLarge?.color),
                ),
                const Icon(Icons.calendar_today, size: 18),
              ],
            ),
          ),
        ),
        // Keterangan
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            widget.isExpense ? 'Keterangan Pengeluaran' : 'Keterangan',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        TextField(
          controller: _descController,
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: InputBorder.none,
            hintText: widget.isExpense ? 'Masukkan keterangan pengeluaran' : 'Masukkan keterangan',
          ),
          onChanged: (val) => _updateData(),
        ),
        const SizedBox(height: 8),
        // Nominal
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Nominal Pembayaran',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ),
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [CurrencyInputFormatter()],
          decoration: InputDecoration(
            filled: true,
            fillColor: Theme.of(context).cardColor,
            border: InputBorder.none,
          ),
          onChanged: (val) => _updateData(),
        ),
        const SizedBox(height: 16),
        Divider(color: Theme.of(context).dividerColor),
        const SizedBox(height: 16),
      ],
    );
  }
}