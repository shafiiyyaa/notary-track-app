import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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

  final _initialFeeController = TextEditingController();
  final _additionalFee1Controller = TextEditingController();
  final _additionalFee2Controller = TextEditingController();

  List<Map<String, dynamic>> _documentTypes = [];
  int? _selectedDocumentTypeId;

  bool _isLoading = false;
  double _totalPrice = 0;
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
    _selectedStatus = widget.document.status;

    _initialFeeController.text = doc.initialFee.toStringAsFixed(0);
    _additionalFee1Controller.text = doc.additionalFee1.toStringAsFixed(0);
    _additionalFee2Controller.text = doc.additionalFee2.toStringAsFixed(0);

    _calculateTotal();
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
  void onDocumentLoaded(DocumentModel document) {
    _nameController.text = document.clientName;
    _phoneController.text = document.phone;
    _deadlineController.text = document.deadline;
    _noteController.text = document.notes;

    _initialFeeController.text = document.initialFee.toStringAsFixed(0);
    _additionalFee1Controller.text =
        document.additionalFee1.toStringAsFixed(0);
    _additionalFee2Controller.text =
        document.additionalFee2.toStringAsFixed(0);

    _selectedDocumentTypeId = document.documentTypeId;
    _selectedStaffId = document.staffId;
    _selectedStatus = document.status;

    _totalPrice = document.totalPrice;

    setState(() {});
  }

  @override
  void onUpdateSuccess() {
    Navigator.pop(context, true);
  }

  @override
  void onError(String message) {
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
                  prefixIcon: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                items: _staffs.map((staff) {
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

              _buildLabel(context, "Status"),
              DropdownButtonFormField<String>(
                initialValue: _selectedStatus,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Theme.of(context).cardColor,
                  border: InputBorder.none,
                ),
                items: const [
                  DropdownMenuItem(
                    value: "Belum Diproses",
                    child: Text("Belum Diproses"),
                  ),
                  DropdownMenuItem(
                    value: "Diproses",
                    child: Text("Diproses"),
                  ),
                  DropdownMenuItem(
                    value: "Selesai",
                    child: Text("Selesai"),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedStatus = value;
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
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Theme.of(context).colorScheme.primary,
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
                          );
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          "Update Dokumen",
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