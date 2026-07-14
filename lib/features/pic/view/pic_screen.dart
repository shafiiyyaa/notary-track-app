import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/staff_model.dart';
import '../../client/model/client_model.dart';
import '../presenter/pic_presenter.dart';
import '../../client/presenter/client_presenter.dart';
import 'pic_view.dart';
import '../../client/view/client_view.dart';

class PicScreen extends StatefulWidget {
  const PicScreen({super.key});

  @override
  State<PicScreen> createState() => _PicScreenState();
}

class _PicScreenState extends State<PicScreen>
    implements PicViewContract, ClientViewContract {
  late PicPresenter _picPresenter;
  late ClientPresenter _clientPresenter;

  List<StaffModel> _staffList = [];
  List<ClientModel> _clientList = [];
  bool _isLoadingStaff = false;
  bool _isLoadingClient = false;

  final _searchController = TextEditingController();
  String _searchQuery = '';

  // Semua / PIC / Klien
  String _filterMode = 'Semua';

  final List<String> _filterModeList = ['Semua', 'PIC', 'Klien'];

  bool get _hasActiveFilter => _filterMode != 'Semua';

  @override
  void initState() {
    super.initState();
    _picPresenter = PicPresenter(this);
    _clientPresenter = ClientPresenter(this);
    _picPresenter.fetchStaffList();
    _clientPresenter.fetchClients();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ================= PicViewContract =================
  @override
  void showLoading() => setState(() => _isLoadingStaff = true);

  @override
  void hideLoading() => setState(() => _isLoadingStaff = false);

  @override
  void onStaffLoaded(List<StaffModel> staffList) =>
      setState(() => _staffList = staffList);

  // ================= ClientViewContract (nama method beda biar gak bentrok) =================
  @override
  void onClientsLoaded(List<ClientModel> clientList) =>
      setState(() => _clientList = clientList);

  // Dipakai bareng oleh PIC & Client presenter (nama method sama persis di kedua contract)
  @override
  void onActionSuccess(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  void onError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // ================= Filtering =================
  List<StaffModel> get _filteredStaff {
    if (_filterMode == 'Klien') return [];
    return _staffList.where((s) {
      return _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  List<ClientModel> get _filteredClients {
    if (_filterMode == 'PIC') return [];
    return _clientList.where((c) {
      return _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery) ||
          c.username.toLowerCase().contains(_searchQuery);
    }).toList();
  }

  int get _totalCount => _staffList.length + _clientList.length;
  int get _filteredCount => _filteredStaff.length + _filteredClients.length;

  // ================= Filter Bottom Sheet =================
  Future<void> _openFilterSheet() async {
    // Nilai sementara di dalam sheet, baru di-commit ke state utama kalau user tekan "Filter".
    String tempFilterMode = _filterMode;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(sheetContext).viewInsets.bottom + 20,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Tampilkan daftar PIC dan klien sesuai dengan kebutuhan anda.',
                    style: GoogleFonts.comfortaa(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildFilterDropdown(
                    context: context,
                    hint: 'Tampilkan Semua',
                    value: tempFilterMode,
                    items: _filterModeList,
                    itemLabelBuilder: (mode) {
                      switch (mode) {
                        case 'PIC':
                          return 'Hanya PIC';
                        case 'Klien':
                          return 'Hanya Klien';
                        default:
                          return 'Tampilkan Semua';
                      }
                    },
                    onChanged: (value) =>
                        setSheetState(() => tempFilterMode = value ?? 'Semua'),
                  ),
                  const SizedBox(height: 24),

                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            setState(() {
                              _filterMode = tempFilterMode;
                            });
                            Navigator.pop(sheetContext);
                          },
                          child: const Text('Filter'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: OutlinedButton(
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => Navigator.pop(sheetContext),
                          child: const Text('Batal'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterDropdown({
    required BuildContext context,
    required String hint,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    String Function(String)? itemLabelBuilder,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        filled: true,
        fillColor: Theme.of(context).cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      ),
      hint: Text(hint, style: const TextStyle(fontSize: 13)),
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  itemLabelBuilder != null ? itemLabelBuilder(item) : item,
                  style: const TextStyle(fontSize: 13),
                ),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  void _resetFilter() {
    setState(() => _filterMode = 'Semua');
  }

  // ================= Dialog: PIC =================
  void _showPicFormDialog({StaffModel? existing}) {
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
                  _picPresenter.updateStaff(existing.id, controller.text);
                } else {
                  _picPresenter.addStaff(controller.text);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeletePic(StaffModel staff) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus PIC?'),
          content: Text(
            'PIC "${staff.name}" akan dihapus. Tindakan ini tidak bisa dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _picPresenter.deleteStaff(staff.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  // ================= Dialog: Klien =================
  void _showClientFormDialog() {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Tambah Klien'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Nama Klien',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: usernameController,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password (min. 6 karakter)',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _clientPresenter.createClient(
                  name: nameController.text,
                  username: usernameController.text,
                  password: passwordController.text,
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );
  }

  void _confirmDeleteClient(ClientModel client) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Klien?'),
          content: Text(
            'Klien "${client.name}" akan dihapus. Tindakan ini tidak bisa dibatalkan.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _clientPresenter.deleteClient(client.id);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showAddMenu() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.badge_outlined),
                title: const Text('Tambah PIC'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showPicFormDialog();
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_add_alt_outlined),
                title: const Text('Tambah Klien'),
                onTap: () {
                  Navigator.pop(sheetContext);
                  _showClientFormDialog();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final staff = _filteredStaff;
    final clients = _filteredClients;
    final isLoading = _isLoadingStaff || _isLoadingClient;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'PIC & Klien',
                style: GoogleFonts.comfortaa(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Kelola daftar PIC dan akun klien yang terdaftar.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama PIC atau klien...',
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Material(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: _openFilterSheet,
                          child: Padding(
                            padding: const EdgeInsets.all(14),
                            child: Icon(
                              Icons.filter_list,
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ),
                      ),
                      if (_hasActiveFilter)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: Container(
                            width: 10,
                            height: 10,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).scaffoldBackgroundColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),

              if (_hasActiveFilter)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _resetFilter,
                    child: const Text('Reset Filter', style: TextStyle(fontSize: 12)),
                  ),
                ),

              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Menampilkan $_filteredCount dari $_totalCount data',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        children: [
                          if (_filterMode != 'Klien') ...[
                            _sectionHeader(context, 'PIC (${staff.length})'),
                            const SizedBox(height: 8),
                            if (staff.isEmpty)
                              _emptyText(
                                context,
                                _staffList.isEmpty
                                    ? 'Belum ada PIC.'
                                    : 'Tidak ada PIC yang cocok.',
                              )
                            else
                              ...staff.map((s) => _buildStaffCard(context, s)),
                            const SizedBox(height: 20),
                          ],
                          if (_filterMode != 'PIC') ...[
                            _sectionHeader(
                              context,
                              'Klien (${clients.length})',
                            ),
                            const SizedBox(height: 8),
                            if (clients.isEmpty)
                              _emptyText(
                                context,
                                _clientList.isEmpty
                                    ? 'Belum ada klien.'
                                    : 'Tidak ada klien yang cocok.',
                              )
                            else
                              ...clients.map(
                                (c) => _buildClientCard(context, c),
                              ),
                          ],
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddMenu,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: Theme.of(context).textTheme.titleLarge?.color,
      ),
    );
  }

  Widget _emptyText(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: Theme.of(
            context,
          ).textTheme.bodyMedium?.color?.withOpacity(0.6),
        ),
      ),
    );
  }

  Widget _buildStaffCard(BuildContext context, StaffModel staff) {
    final initials = staff.name.isNotEmpty
        ? staff.name
              .trim()
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase()
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
            backgroundColor: Theme.of(
              context,
            ).colorScheme.primary.withOpacity(0.15),
            child: Text(
              initials,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  staff.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${staff.jobCount} pekerjaan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _showPicFormDialog(existing: staff),
            icon: Icon(
              Icons.edit_outlined,
              size: 20,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          IconButton(
            onPressed: () => _confirmDeletePic(staff),
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, ClientModel client) {
    final initials = client.name.isNotEmpty
        ? client.name
              .trim()
              .split(' ')
              .map((w) => w.isNotEmpty ? w[0] : '')
              .take(2)
              .join()
              .toUpperCase()
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
            backgroundColor: Colors.blueGrey.withOpacity(0.15),
            child: Text(
              initials,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blueGrey,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  client.name,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '@${client.username} • ${client.jobCount} pekerjaan',
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDeleteClient(client),
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
          ),
        ],
      ),
    );
  }
}