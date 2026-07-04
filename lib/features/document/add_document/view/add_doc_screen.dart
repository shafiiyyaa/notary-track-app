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

  bool _isLoading = false;
  double _totalPrice = 0;
  String _staffName = "-";
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
    _loadCurrentStaff();
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

  Future<void> _loadCurrentStaff() async {
    final name = await _presenter.getCurrentStaffName();

    if (!mounted) return;

    setState(() {
      _staffName = name;
    });
  }

  void _calculateTotal() {
    final awal =
        double.tryParse(
          _initialFeeController.text.replaceAll('.', '').replaceAll(',', '.'),
        ) ??
        0;

    final tambah1 =
        double.tryParse(
          _additionalFee1Controller.text
              .replaceAll('.', '')
              .replaceAll(',', '.'),
        ) ??
        0;

    final tambah2 =
        double.tryParse(
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
  void showLoading() {
    setState(() => _isLoading = true);
  }

  @override
  void hideLoading() {
    setState(() => _isLoading = false);
  }

  @override
  void onSaveSuccess() {
    Navigator.pop(context);
  }

  @override
  void onSaveError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
              
              _buildLabel('Nama Klien'),
              TextField(
                controller: _nameController,
                textInputAction: TextInputAction.next,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                ),
              ),

              _buildLabel('Nomor Telepon'),
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(15),
                ],
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                ),
              ),

              _buildLabel('Jenis Dokumen'),

              DropdownButtonFormField<int>(
                initialValue: _selectedDocumentTypeId,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
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
              _buildLabel("Staff Penanggung Jawab"),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person, color: AppColors.primaryBlue),
                    const SizedBox(width: 10),
                    Text(
                      _staffName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),
              _buildLabel('Deadline'),
              TextField(
                controller: _deadlineController,
                readOnly: true,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  suffixIcon: Icon(Icons.calendar_today),
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

              _buildLabel('Biaya Awal'),
              TextField(
                controller: _initialFeeController,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                ),
              ),

              _buildLabel('Biaya Tambahan 1'),
              TextField(
                controller: _additionalFee1Controller,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                ),
              ),

              _buildLabel('Biaya Tambahan 2'),
              TextField(
                controller: _additionalFee2Controller,
                textInputAction: TextInputAction.next,
                keyboardType: TextInputType.number,
                onChanged: (_) => _calculateTotal(),
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                ),
              ),

              _buildLabel('Catatan'),
              TextField(
                controller: _noteController,
                textInputAction: TextInputAction.next,
                maxLines: 3,
                decoration: const InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 20),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Total Biaya",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
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
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          _presenter.saveDocument(
                            name: _nameController.text,
                            phone: _phoneController.text,

                            documentTypeId: _selectedDocumentTypeId!,

                            deadline: _deadlineController.text,

                            initialFee:
                                double.tryParse(
                                  _initialFeeController.text
                                      .replaceAll('.', '')
                                      .replaceAll(',', '.'),
                                ) ??
                                0,

                            additionalFee1:
                                double.tryParse(
                                  _additionalFee1Controller.text
                                      .replaceAll('.', '')
                                      .replaceAll(',', '.'),
                                ) ??
                                0,

                            additionalFee2:
                                double.tryParse(
                                  _additionalFee2Controller.text
                                      .replaceAll('.', '')
                                      .replaceAll(',', '.'),
                                ) ??
                                0,

                            note: _noteController.text,
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator()
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

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
    );
  }
}
