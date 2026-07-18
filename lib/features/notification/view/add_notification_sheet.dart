import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddNotificationSheet extends StatefulWidget {
  const AddNotificationSheet({super.key});

  @override
  State<AddNotificationSheet> createState() => _AddNotificationSheetState();
}

class _AddNotificationSheetState extends State<AddNotificationSheet> {
  final SupabaseClient _supabase = Supabase.instance.client;

  List<Map<String, dynamic>> _clients = [];
  String? _selectedClientId;

  final _titleController = TextEditingController(text: 'Janji Temu');
  final _messageController =
      TextEditingController(); // Ubah dari desc ke message

  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoadingClients = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _fetchClients();
  }

  Future<void> _fetchClients() async {
    try {
      final response = await _supabase
          .from('clients')
          .select('id, name')
          .order('name');
      if (mounted) {
        setState(() {
          _clients = List<Map<String, dynamic>>.from(response);
          _isLoadingClients = false;
        });
      }
    } catch (e) {
      print("Error fetch clients: $e");
      if (mounted) setState(() => _isLoadingClients = false);
    }
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Future<void> _saveNotification() async {
    if (_selectedClientId == null ||
        _selectedDate == null ||
        _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Klien, Tanggal, dan Jam wajib diisi!')),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      // Gabungkan Tanggal dan Jam jadi satu DateTime
      final scheduledDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      final user = _supabase.auth.currentUser;
      final clientName = _clients.firstWhere(
        (c) => c['id'] == _selectedClientId,
      )['name'];

      // 1. Simpan ke Database Supabase (Gunakan kolom 'message' sesuai tabel Anda)
      final insertedData = await _supabase
          .from('notifications')
          .insert({
            'user_id': user?.id,
            'client_id': _selectedClientId,
            'title': _titleController.text,
            'message':
                _messageController.text, // Sesuaikan dengan nama kolom di DB
            'scheduled_at': scheduledDateTime.toIso8601String(),
          })
          .select('id')
          .single();

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      print("Error save notif: $e");
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal menyimpan: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tambah Pengingat',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Dropdown Pilih Klien
            Text('Pilih Klien', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            _isLoadingClients
                ? const Center(child: CircularProgressIndicator())
                : DropdownButtonFormField<String>(
                    initialValue: _selectedClientId,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Pilih Klien',
                    ),
                    items: _clients.map((c) {
                      return DropdownMenuItem<String>(
                        value: c['id'],
                        child: Text(c['name']),
                      );
                    }).toList(),
                    onChanged: (val) => setState(() => _selectedClientId = val),
                  ),
            const SizedBox(height: 16),

            // Input Jenis Pengingat
            Text(
              'Jenis Pengingat',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'cth: Janji Temu, Tanda Tangan',
              ),
            ),
            const SizedBox(height: 16),

            // Input Deskripsi / Pesan
            Text(
              'Deskripsi (Opsional)',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _messageController,
              maxLines: 2,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'cth: Bertemu di kantor notaris',
              ),
            ),
            const SizedBox(height: 16),

            // Pilih Tanggal dan Jam
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tanggal',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickDate,
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _selectedDate == null
                                ? 'Pilih Tanggal'
                                : DateFormat(
                                    'dd MMM yyyy',
                                  ).format(_selectedDate!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Jam',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: _pickTime,
                        child: Container(
                          padding: EdgeInsets.all(15),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            _selectedTime == null
                                ? 'Pilih Jam'
                                : _selectedTime!.format(context),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Tombol Simpan
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveNotification,
                child: _isSaving
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text('Simpan Pengingat'),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
