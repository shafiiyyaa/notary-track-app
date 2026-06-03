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

class _AddDocumentScreenState extends State<AddDocumentScreen> implements AddDocumentViewContract {
  final _nameController = TextEditingController();
  final _deadlineController = TextEditingController();
  final _priceController = TextEditingController();
  final _noteController = TextEditingController();
  String _selectedType = 'Akta Jual Beli';
  bool _isLoading = false;
  late AddDocPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = AddDocPresenter(this);
  }

  @override
  void showLoading() => setState(() => _isLoading = true);
  @override
  void hideLoading() => setState(() => _isLoading = false);
  @override
  void onSaveSuccess() => Navigator.pop(context);
  @override
  void onSaveError(String message) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tambah Dokumen', style: GoogleFonts.comfortaa(fontWeight: FontWeight.bold))),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _buildLabel('Nama Klien'),
          TextField(controller: _nameController, decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: InputBorder.none)),
          _buildLabel('Jenis Dokumen'),
          DropdownButton<String>(
            value: _selectedType,
            isExpanded: true,
            items: ['Akta Jual Beli', 'Pendirian Yayasan', 'Pemecahan Sertifikat'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
            onChanged: (v) => setState(() => _selectedType = v!),
          ),
          _buildLabel('Deadline (YYYY-MM-DD)'),
          TextField(controller: _deadlineController, decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: InputBorder.none)),
          _buildLabel('Total Biaya'),
          TextField(controller: _priceController, keyboardType: TextInputType.number, decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: InputBorder.none)),
          _buildLabel('Catatan'),
          TextField(controller: _noteController, maxLines: 3, decoration: const InputDecoration(filled: true, fillColor: Colors.white, border: InputBorder.none)),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : () => _presenter.saveDocument(name: _nameController.text, type: _selectedType, deadline: _deadlineController.text, price: double.tryParse(_priceController.text) ?? 0, note: _noteController.text),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue),
              child: _isLoading ? const CircularProgressIndicator() : const Text('Simpan Dokumen', style: TextStyle(color: Colors.white)),
            ),
          )
        ]),
      ),
    );
  }

  Widget _buildLabel(String txt) => Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(txt, style: const TextStyle(fontWeight: FontWeight.bold)));
}