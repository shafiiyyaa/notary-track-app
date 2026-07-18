import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../constants/constants.dart'; // Sesuaikan path constants Anda

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _myDocuments = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyDocuments();
  }

  Future<void> _fetchMyDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getString('user_id');


    print("DEBUG: Mencoba fetch dokumen untuk client_id: $clientId");


    if (clientId == null || clientId.isEmpty) {
      print("DEBUG: Client ID tidak ditemukan di SharedPreferences!");
      if (!mounted) return;
      setState(() {
        _myDocuments = [];
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await _supabase
          .from('documents')
          .select('*, document_types(name)')
          .eq('client_id', clientId)
          .order('deadline', ascending: false);

      // CEK HASIL DARI DATABASE
      print("DEBUG: Jumlah dokumen ditemukan: ${response.length}");

      if (!mounted) return;
      setState(() {
        _myDocuments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      // JIKA ADA ERROR DARI SUPABASE (Misal: RLS memblokir)
      print("ERROR FETCH CLIENT DOCS: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Dokumen Saya",
                  style: GoogleFonts.comfortaa(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.titleLarge?.color,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _myDocuments.isEmpty
                      ? const Center(child: Text('Belum ada dokumen untuk Anda'))
                      : RefreshIndicator(
                          onRefresh: _fetchMyDocuments,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _myDocuments.length,
                            itemBuilder: (context, index) {
                              final doc = _myDocuments[index];
                              final docType = doc['document_types']?['name'] ?? 'Dokumen';
                              final status = doc['status'] ?? 'Belum Diproses';
                              final deadline = doc['deadline'] ?? '-';

                              Color statusColor = AppColors.statusBelumProses;
                              if (status == 'Diproses') statusColor = AppColors.statusDiproses;
                              if (status == 'Selesai') statusColor = AppColors.statusSelesai;
                              if (status == 'Tertunda') statusColor = AppColors.statusTertunda;
                              if (status == 'Batal') statusColor = AppColors.statusBatal;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 16),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                child: Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: Theme.of(context).dividerColor,
                                      child: Icon(Icons.article_outlined, color: Theme.of(context).textTheme.bodyLarge?.color),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(docType, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                          const SizedBox(height: 5),
                                          Text('Deadline: $deadline', style: TextStyle(fontSize: 13, color: Colors.grey[600])),
                                          const SizedBox(height: 10),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor,
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}