import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/client_model.dart';
import '../presenter/client_presenter.dart';
import 'client_view.dart';

class ClientScreen extends StatefulWidget {
  const ClientScreen({super.key});

  @override
  State<ClientScreen> createState() => _ClientScreenState();
}

class _ClientScreenState extends State<ClientScreen> implements ClientViewContract {
  late ClientPresenter _presenter;
  List<ClientModel> _clientList = [];
  bool _isLoading = false;

  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _filterMode = 'Semua';

  @override
  void initState() {
    super.initState();
    _presenter = ClientPresenter(this);
    _presenter.fetchClients();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text.toLowerCase());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onClientsLoaded(List<ClientModel> clients) => setState(() => _clientList = clients);

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

  List<ClientModel> get _filteredList {
    return _clientList.where((c) {
      final matchSearch = _searchQuery.isEmpty ||
          c.name.toLowerCase().contains(_searchQuery) ||
          c.username.toLowerCase().contains(_searchQuery);
      final matchFilter = _filterMode == 'Semua' ||
          (_filterMode == 'Ada Dokumen' && c.jobCount > 0) ||
          (_filterMode == 'Belum Ada Dokumen' && c.jobCount == 0);
      return matchSearch && matchFilter;
    }).toList();
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (sheetContext, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Filter Klien',
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    initialValue: _filterMode,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Theme.of(context).cardColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
                    ),
                    items: const [
                      DropdownMenuItem(value: 'Semua', child: Text('Semua Klien')),
                      DropdownMenuItem(value: 'Ada Dokumen', child: Text('Ada Dokumen')),
                      DropdownMenuItem(value: 'Belum Ada Dokumen', child: Text('Belum Ada Dokumen')),
                    ],
                    onChanged: (v) => setSheetState(() => setState(() => _filterMode = v ?? 'Semua')),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: TextButton(
                      onPressed: () => setSheetState(() => setState(() => _filterMode = 'Semua')),
                      child: const Text('Reset Filter'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final usernameController = TextEditingController();
    final passwordController = TextEditingController();
    bool obscurePassword = true;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: const Text('Tambah Klien'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nama Klien', border: OutlineInputBorder()),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: usernameController,
                      decoration: const InputDecoration(
                        labelText: 'Username Login',
                        hintText: 'cth: budi123',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Minimal 6 karakter',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setDialogState(() => obscurePassword = !obscurePassword),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _presenter.createClient(
                      name: nameController.text,
                      username: usernameController.text,
                      password: passwordController.text,
                    );
                  },
                  child: const Text('Buat Akun'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(ClientModel client) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Klien?'),
          content: Text('Klien "${client.name}" akan dihapus. Tindakan ini tidak bisa dibatalkan.'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Batal')),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _presenter.deleteClient(client.id);
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
    final filtered = _filteredList;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Kelola Daftar Klien',
                style: GoogleFonts.comfortaa(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Tambah klien beserta akun login (username & password) yang bisa dipakai klien untuk memantau dokumennya.',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Cari nama / username klien...',
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
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: _showFilterSheet,
                      icon: Icon(
                        Icons.filter_list,
                        color: _filterMode != 'Semua'
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Menampilkan ${filtered.length} dari ${_clientList.length} klien',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                ),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : filtered.isEmpty
                        ? Center(
                            child: Text(
                              _clientList.isEmpty
                                  ? 'Belum ada klien. Tekan tombol + untuk menambah.'
                                  : 'Tidak ada klien yang cocok',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (context, index) => _buildClientCard(context, filtered[index]),
                          ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildClientCard(BuildContext context, ClientModel client) {
    final initials = client.name.isNotEmpty
        ? client.name.trim().split(' ').map((w) => w.isNotEmpty ? w[0] : '').take(2).join().toUpperCase()
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
            child: Text(initials,
                style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(client.name,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text('@${client.username}',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
                Text('${client.jobCount} dokumen',
                    style: TextStyle(
                        fontSize: 12,
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6))),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _confirmDelete(client),
            icon: const Icon(Icons.delete_outline, size: 20, color: Colors.red),
          ),
        ],
      ),
    );
  }
}