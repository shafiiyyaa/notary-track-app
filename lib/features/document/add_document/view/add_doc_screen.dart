import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/constants.dart';
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

  final _initialFeeController = TextEditingController();
  final _additionalFee1Controller = TextEditingController();
  final _additionalFee2Controller = TextEditingController();

  List<Map<String, dynamic>> _documentTypes = [];
  int? _selectedDocumentTypeId;

  List<Map<String, dynamic>> _staffList = [];
  String? _selectedStaffId;

  bool _isLoading = false;
  double _totalPrice = 0;
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
      if (data.isNotEmpty) {
        _selectedDocumentTypeId = data.first['id'];
      }
    });
  }

  Future<void> _loadStaffList() async {
    final data = await _presenter.getStaffList();
    if (!mounted) return;
    setState(() {
      _staffList = data;
      if (data.isNotEmpty) {
        _selectedStaffId = data.first['id'];
      }
    });
  }

  void _calculateTotal() {
    final awal = double.tryParse(
          _initialFeeController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;
    final tambah1 = double.tryParse(
          _additionalFee1Controller.text
              .replaceAll('.', '')
              .replaceAll(',', '.'),
        ) ??
        0;
    final tambah2 = double.tryParse(
          _additionalFee2Controller.text
              .replaceAll('.', '')
              .replaceAll(',', '.'),
        ) ??
        0;

    setState(() {
      _totalPrice = awal + tambah1 + tambah2;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _deadlineController.dispose();
    _noteController.dispose();
    _initialFeeController.dispose();
    _additionalFee1Controller.dispose();
    _additionalFee2Controller.dispose();
    super.dispose();
  }

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onSaveSuccess() => Navigator.pop(context);

  @override
  void onSaveError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
                    splashRadius: 22,
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
                textInputAction: TextInputAction.next,
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
                textInputAction: TextInputAction.next,
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
                items: _documentTypes.map((doc) {
                  return DropdownMenuItem<int>(
                    value: doc['id'],
                    child: Text(doc['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDocumentTypeId = value;
                  });
                },
              ),

              _buildLabel(context, "Staff Penanggung Jawab"),
              DropdownButtonFormField<String>(
                initialValue: _selectedStaffId,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                  prefixIcon: const Icon(Icons.person, color: AppColors.primaryBlue),
                ),
                items: _staffList.map((staff) {
                  return DropdownMenuItem<String>(
                    value: staff['id'],
                    child: Text(staff['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedStaffId = value;
                  });
                },
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
                onTap: () async {
                  DateTime? picked = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2024),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    _deadlineController.text =
                        "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                  }
                },
              ),

              _buildLabel(context, 'Biaya Awal'),
              TextField(
                controller: _initialFeeController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              _buildLabel(context, 'Biaya Tambahan 1'),
              TextField(
                controller: _additionalFee1Controller,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              _buildLabel(context, 'Biaya Tambahan 2'),
              TextField(
                controller: _additionalFee2Controller,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
              ),

              _buildLabel(context, 'Catatan'),
              TextField(
                controller: _noteController,
                textInputAction: TextInputAction.next,
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
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Total Biaya",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                    Text(
                      _rupiah.format(_totalPrice),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Text(
                "*Total biaya dihitung otomatis",
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  fontSize: 12,
                ),
              ),
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
                            initialFee: double.tryParse(
                                  _initialFeeController.text
                                      .replaceAll('.', '')
                                      .replaceAll(',', '.'),
                                ) ??
                                0,
                            additionalFee1: double.tryParse(
                                  _additionalFee1Controller.text
                                      .replaceAll('.', '')
                                      .replaceAll(',', '.'),
                                ) ??
                                0,
                            additionalFee2: double.tryParse(
                                  _additionalFee2Controller.text
                                      .replaceAll('.', '')
                                      .replaceAll(',', '.'),
                                ) ??
                                0,
                            note: _noteController.text,
                            staffId: _selectedStaffId!,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
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