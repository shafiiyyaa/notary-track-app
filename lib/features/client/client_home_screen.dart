import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../constants/constants.dart';
import '../document/detail_document/view/detail_doc_screen.dart';

class ClientHomeScreen extends StatefulWidget {
  const ClientHomeScreen({super.key});

  @override
  State<ClientHomeScreen> createState() => _ClientHomeScreenState();
}

class _ClientHomeScreenState extends State<ClientHomeScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _myDocuments = [];
  bool _isLoading = true;
  bool _isRefreshing = false;
  final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _fetchMyDocuments();
  }

  Future<void> _fetchMyDocuments() async {
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getString('user_id');

    if (clientId == null || clientId.isEmpty) {
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
          .select('*, document_types(name), staff(name)')
          .eq('client_id', clientId)
          .order('deadline', ascending: false);

      if (!mounted) return;
      setState(() {
        _myDocuments = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print("ERROR FETCH CLIENT DOCS: $e");
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    await _fetchMyDocuments();
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isRefreshing = false);
  }

  DateTime _parseTz(dynamic input) {
    if (input == null) return DateTime.now();
    String str = input.toString();
    DateTime dt = DateTime.parse(str);
    if (str.contains('Z') || str.contains('+00:00')) {
      return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
    }
    return dt;
  }

  // ⚡ UBAH FORMAT: Tanggal di atas, Jam AM/PM di bawah
  String _formatDeadline(dynamic deadlineInput) {
    if (deadlineInput == null) return '-';
    String str = deadlineInput.toString();
    if (str.isEmpty) return '-';
    try {
      DateTime dt = _parseTz(str);
      String dateStr = DateFormat('dd MMM yyyy', 'id_ID').format(dt);
      String timeStr = DateFormat(
        'hh.mm a',
        'en_US',
      ).format(dt); // Format 09.45 PM
      return '$dateStr\n$timeStr'; // Pakai \n agar turun ke bawah
    } catch (e) {
      return str;
    }
  }

  Widget _buildHeader(BuildContext context) {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      color: Theme.of(context).colorScheme.primary,
      child: Row(
        children: [
          SizedBox(
            width: 42,
            height: 42,
            child: Image.asset(
              "assets/images/logo notaris.png",
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "SAPTADI SETYA NUGRAHA, S.H., M.M., M.Kn.",
                  style: GoogleFonts.comfortaa(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  "Monitoring Dokumen Saya — $today",
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              onPressed: _isRefreshing ? null : _handleRefresh,
              icon: _isRefreshing
                  ? SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : Icon(
                      Icons.refresh,
                      size: 18,
                      color: Theme.of(context).colorScheme.primary,
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<String> mendekatiDeadline = [];
    List<String> terlambat = [];
    List<String> belumLunas = [];

    for (var doc in _myDocuments) {
      final status = doc['status'] ?? 'Belum Diproses';
      if (status == 'Selesai' || status == 'Batal') continue;

      final docType = doc['document_types']?['name'] ?? 'Dokumen';
      final deadlineDate = _parseTz(doc['deadline']);
      final remainingDays = deadlineDate.difference(DateTime.now()).inDays;

      if (deadlineDate.isBefore(DateTime.now())) {
        terlambat.add('$docType • Lewat ${remainingDays.abs()} hari');
      } else if (remainingDays <= 14) {
        mendekatiDeadline.add('$docType • $remainingDays hari lagi');
      }

      final kesepakatan = (doc['kesepakatan_biaya'] as num?)?.toDouble() ?? 0;
      final uangMuka = (doc['uang_muka_jumlah'] as num?)?.toDouble() ?? 0;
      final tambahan = (doc['tambahan_jumlah'] as num?)?.toDouble() ?? 0;
      final sisaTagihan = kesepakatan - (uangMuka + tambahan);

      if (kesepakatan > 0 && sisaTagihan > 0) {
        belumLunas.add('$docType • ${_rupiah.format(sisaTagihan)}');
      }
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(context),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Daftar Dokumen",
                              style: GoogleFonts.comfortaa(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 12),

                            _myDocuments.isEmpty
                                ? const Center(
                                    child: Text('Belum ada dokumen untuk Anda'),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount: _myDocuments.length,
                                    itemBuilder: (context, index) {
                                      final doc = _myDocuments[index];
                                      final docType =
                                          doc['document_types']?['name'] ??
                                          'Dokumen';
                                      final status =
                                          doc['status'] ?? 'Belum Diproses';
                                      final docId = doc['id'].toString();

                                      bool isLate = false;
                                      if (status != 'Selesai' &&
                                          status != 'Batal') {
                                        final deadlineStr = doc['deadline'];
                                        if (deadlineStr != null) {
                                          DateTime dt = _parseTz(deadlineStr);
                                          if (dt.isBefore(DateTime.now())) {
                                            isLate = true;
                                          }
                                        }
                                      }
                                      final displayStatus = isLate
                                          ? 'Terlambat'
                                          : status;

                                      final kesepakatan =
                                          (doc['kesepakatan_biaya'] as num?)
                                              ?.toDouble() ??
                                          0;
                                      final uangMuka =
                                          (doc['uang_muka_jumlah'] as num?)
                                              ?.toDouble() ??
                                          0;
                                      final tambahan =
                                          (doc['tambahan_jumlah'] as num?)
                                              ?.toDouble() ??
                                          0;
                                      final totalDibayar = uangMuka + tambahan;
                                      final sisaTagihan =
                                          kesepakatan - totalDibayar;

                                      Color statusColor =
                                          AppColors.statusBelumProses;
                                      if (displayStatus == 'Diproses') {
                                        statusColor = AppColors.statusDiproses;
                                      }
                                      if (displayStatus == 'Selesai') {
                                        statusColor = AppColors.statusSelesai;
                                      }
                                      if (displayStatus == 'Tertunda') {
                                        statusColor = AppColors.statusTertunda;
                                      }
                                      if (displayStatus == 'Batal') {
                                        statusColor = AppColors.statusBatal;
                                      }
                                      if (displayStatus == 'Terlambat') {
                                        statusColor = Colors.red.shade700;
                                      }

                                      return InkWell(
                                        onTap: () {
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  DetailDocumentScreen(
                                                    documentId: docId,
                                                    userRole: 'Klien',
                                                  ),
                                            ),
                                          );
                                        },
                                        borderRadius: BorderRadius.circular(24),
                                        child: Container(
                                          margin: const EdgeInsets.only(
                                            bottom: 16,
                                          ),
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Theme.of(context).cardColor,
                                            borderRadius: BorderRadius.circular(
                                              24,
                                            ),
                                            border: Border.all(
                                              color: isLate
                                                  ? Colors.red.shade700
                                                        .withOpacity(0.5)
                                                  : Colors.transparent,
                                              width: 1.5,
                                            ),
                                          ),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor: Theme.of(
                                                      context,
                                                    ).dividerColor,
                                                    child: Icon(
                                                      isLate
                                                          ? Icons
                                                                .warning_amber_rounded
                                                          : Icons
                                                                .article_outlined,
                                                      color: isLate
                                                          ? Colors.red.shade700
                                                          : Theme.of(context)
                                                                .textTheme
                                                                .bodyLarge
                                                                ?.color,
                                                    ),
                                                  ),
                                                  const SizedBox(width: 16),
                                                  Expanded(
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          docType,
                                                          style:
                                                              const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 16,
                                                              ),
                                                        ),
                                                        const SizedBox(
                                                          height: 5,
                                                        ),
                                                        // ⚡ TAMBAHKAN maxLines: 2 agar jam bisa turun ke bawah
                                                        Text(
                                                          'Deadline: ${_formatDeadline(doc['deadline'])}',
                                                          maxLines: 2,
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: isLate
                                                                ? Colors
                                                                      .red
                                                                      .shade700
                                                                : Colors
                                                                      .grey[600],
                                                            fontWeight: isLate
                                                                ? FontWeight
                                                                      .bold
                                                                : FontWeight
                                                                      .normal,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          height: 8,
                                                        ),
                                                        Container(
                                                          padding:
                                                              const EdgeInsets.symmetric(
                                                                horizontal: 12,
                                                                vertical: 4,
                                                              ),
                                                          decoration: BoxDecoration(
                                                            color: statusColor,
                                                            borderRadius:
                                                                BorderRadius.circular(
                                                                  12,
                                                                ),
                                                          ),
                                                          child: Text(
                                                            displayStatus,
                                                            style:
                                                                const TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 11,
                                                                ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const Divider(height: 24),
                                              _buildFinanceRow(
                                                "Total Biaya",
                                                _rupiah.format(kesepakatan),
                                              ),
                                              _buildFinanceRow(
                                                "Sudah Dibayar",
                                                _rupiah.format(totalDibayar),
                                                color: Colors.green,
                                              ),
                                              _buildFinanceRow(
                                                "Kurang Bayar",
                                                _rupiah.format(
                                                  sisaTagihan < 0
                                                      ? 0
                                                      : sisaTagihan,
                                                ),
                                                color: Colors.red.shade700,
                                                isBold: true,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                            const SizedBox(height: 30),

                            if (_myDocuments.isNotEmpty) ...[
                              Text(
                                "Pengingat Dokumen & Tagihan",
                                style: GoogleFonts.comfortaa(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(
                                    context,
                                  ).textTheme.titleLarge?.color,
                                ),
                              ),
                              const SizedBox(height: 12),
                              _buildReminderCard(
                                context,
                                "Mendekati Deadline (≤14 hari)",
                                Icons.calendar_today,
                                AppColors.statusDiproses,
                                mendekatiDeadline.isEmpty
                                    ? null
                                    : mendekatiDeadline,
                              ),
                              const SizedBox(height: 10),
                              _buildReminderCard(
                                context,
                                "Terlambat",
                                Icons.error_outline,
                                Colors.red.shade700,
                                terlambat.isEmpty ? null : terlambat,
                              ),
                              const SizedBox(height: 10),
                              _buildReminderCard(
                                context,
                                "Belum Lunas",
                                Icons.attach_money,
                                AppColors.statusTertunda,
                                belumLunas.isEmpty ? null : belumLunas,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinanceRow(
    String label,
    String value, {
    Color? color,
    bool isBold = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: color ?? Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard(
    BuildContext context,
    String title,
    IconData icon,
    Color accent,
    List<String>? items,
  ) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: accent),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items == null || items.isEmpty)
            Text(
              "Tidak ada 🎉",
              style: TextStyle(
                fontSize: 12,
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.6),
              ),
            )
          else
            ...items.map(
              (t) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  "• $t",
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
