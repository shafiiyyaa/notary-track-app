import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/staff_model.dart';
import '../presenter/pic_presenter.dart';
import 'pic_view.dart';

class PicScreen extends StatefulWidget {
  const PicScreen({super.key});

  @override
  State<PicScreen> createState() => _PicScreenState();
}

class _PicScreenState extends State<PicScreen> implements PicViewContract {
  late PicPresenter _presenter;
  List<StaffModel> _staffList = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _presenter = PicPresenter(this);
    _presenter.fetchStaffList();
  }

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onStaffLoaded(List<StaffModel> staffList) => setState(() => _staffList = staffList);

  @override
  void onActionSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void onError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showFormDialog({StaffModel? existing}) {
    final controller = TextEditingController(text: existing?.name ?? '');
    final isEdit = existing != null;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(isEdit ? 'Edit PIC' : 'Tambah PIC'),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: const InputDecoration(
              hintText: 'cth: Staff Arsip',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                if (isEdit) {
                  _presenter.updateStaff(existing.id, controller.text);
                } else {
                  _presenter.addStaff(controller.text);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(StaffModel staff) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus PIC?'),
          content: Text('PIC "${staff.name}" akan dihapus. Tindakan ini tidak bisa dibatalkan.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _presenter.deleteStaff(staff.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelola Daftar PIC',
                style: GoogleFonts.comfortaa(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tambah, ubah nama, atau hapus PIC. Mengubah nama otomatis memperbarui seluruh dokumen yang memakainya.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _staffList.isEmpty
                        ? Center(
                            child: Text(
                              'Belum ada PIC. Tekan tombol + untuk menambah.',
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: _staffList.length,
                            itemBuilder: (context, index) => _buildStaffCard(context, _staffList[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showFormDialog(),
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffModel staff) {
    final initials = staff.name.isNotEmpty
        ? staff.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
        : '?';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.15),
            child: Text(
              initials,
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(staff.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                const SizedBox(height: 2),
                Text('${staff.jobCount} pekerjaan',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showFormDialog(existing: staff),
            icon: Icon(Icons.edit_outlined, size: 20, color: Theme.of(context).colorScheme.primary),
          ),
          IconButton(
            onPressed: () => _confirmDelete(staff),
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
          ),
        ],
      ),
    );
  }
}