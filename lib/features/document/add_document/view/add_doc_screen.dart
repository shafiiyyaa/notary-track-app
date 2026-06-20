import 'package:flutter/material.dart';
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

  bool _isLoading = false;

  late AddDocPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = AddDocPresenter(this);
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
      appBar: AppBar(
        title: Text(
          'Tambah Dokumen',
          style: GoogleFonts.comfortaa(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _buildLabel('Nama Klien'),
            TextField(
              controller: _nameController,
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
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
              ),
            ),

            _buildLabel('Deadline (YYYY-MM-DD)'),
            TextField(
              controller: _deadlineController,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
              ),
            ),

            _buildLabel('Biaya Awal'),
            TextField(
              controller: _initialFeeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
              ),
            ),

            _buildLabel('Biaya Tambahan 1'),
            TextField(
              controller: _additionalFee1Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
              ),
            ),

            _buildLabel('Biaya Tambahan 2'),
            TextField(
              controller: _additionalFee2Controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
              ),
            ),

            _buildLabel('Catatan'),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: InputBorder.none,
              ),
            ),

            const SizedBox(height: 30),

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

                          documentTypeId: 1,

                          deadline: _deadlineController.text,

                          initialFee: double.tryParse(
                                _initialFeeController.text,
                              ) ??
                              0,

                          additionalFee1: double.tryParse(
                                _additionalFee1Controller.text,
                              ) ??
                              0,

                          additionalFee2: double.tryParse(
                                _additionalFee2Controller.text,
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
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}