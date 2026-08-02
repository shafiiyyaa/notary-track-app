import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// PENTING: Sesuaikan path import ini dengan struktur folder kamu
import '../notification/services/notification_service.dart'; 

class ClientNotificationScreen extends StatefulWidget {
  const ClientNotificationScreen({super.key});

  @override
  State<ClientNotificationScreen> createState() =>
      _ClientNotificationScreenState();
}

class _ClientNotificationScreenState extends State<ClientNotificationScreen> {
  final SupabaseClient _supabase = Supabase.instance.client;
  List<Map<String, dynamic>> _notifList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchMyNotifications();
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

  Future<void> _fetchMyNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getString('user_id');

    if (clientId == null || clientId.isEmpty) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      return;
    }

    try {
      // 1. Ambil Deadline Dokumen Klien & Jadwalkan Alarm H-14 s/d H-5 detik
      final docsResponse = await _supabase
          .from('documents')
          .select('id, deadline, status, document_types(name)')
          .eq('client_id', clientId);

      for (final doc in docsResponse) {
        final status = doc['status'] ?? 'Belum Diproses';
        // FIX ERROR: Pastikan ID di-parse ke int
        final docId = doc['id'] is int ? doc['id'] : int.tryParse(doc['id'].toString()) ?? 0;
        
        if (status == 'Selesai' || status == 'Batal') {
          await NotificationService().cancelForDocument(docId);
          continue;
        }

        await NotificationService().scheduleForDocument(
          docId: docId,
          clientName: 'Anda',
          documentType: doc['document_types']?['name'] ?? 'Dokumen',
          deadline: _parseTz(doc['deadline']),
        );
      }

      // 2. Ambil Janji Temu Manual Klien & Jadwalkan Alarm
      final manualResponse = await _supabase
          .from('notifications')
          .select('id, title, message, scheduled_at')
          .eq('client_id', clientId)
          .gte('scheduled_at', DateTime.now().toUtc().toIso8601String())
          .order('scheduled_at', ascending: true);

      for (final item in manualResponse) {
        final schedDate = _parseTz(item['scheduled_at']);
        // FIX ERROR: Pastikan ID di-parse ke int
        final notifId = item['id'] is int ? item['id'] : int.tryParse(item['id'].toString()) ?? 0;
        int baseId = (notifId % 200000) * 10;
        
        await NotificationService().scheduleAppointmentReminders(
          baseId: baseId,
          clientName: 'Anda',
          location: '',
          message: item['message'] ?? '',
          appointmentTime: schedDate,
        );
      }

      // 3. Gabungkan keduanya untuk ditampilkan di UI
      List<Map<String, dynamic>> combinedList = [];

      for (final doc in docsResponse) {
        final status = doc['status'] ?? 'Belum Diproses';
        if (status == 'Selesai' || status == 'Batal') continue;

        final deadline = _parseTz(doc['deadline']);
        final remainingDays = deadline.difference(DateTime.now()).inDays;
        
        if (remainingDays <= 14) {
          combinedList.add({
            'title': 'Deadline ${doc['document_types']?['name'] ?? 'Dokumen'}',
            'subtitle': 'Deadline dokumen',
            'message': 'Batas waktu: ${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(deadline)}',
            'scheduled_at': deadline.toIso8601String(),
            'isManual': false,
          });
        }
      }

      for (final item in manualResponse) {
        combinedList.add({
          'title': item['title'] ?? 'Pengingat',
          'subtitle': 'Janji Temu',
          'message': item['message'] ?? '',
          'scheduled_at': item['scheduled_at'],
          'isManual': true,
        });
      }

      // Urutkan berdasarkan waktu terdekat
      combinedList.sort((a, b) {
        final dateA = _parseTz(a['scheduled_at']);
        final dateB = _parseTz(b['scheduled_at']);
        return dateA.compareTo(dateB);
      });

      if (!mounted) return;
      setState(() {
        _notifList = combinedList;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error fetch client notif: $e");
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
                  'Notifikasi Saya',
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
                  : _notifList.isEmpty
                      ? const Center(child: Text("Tidak ada notifikasi aktif"))
                      : RefreshIndicator(
                          onRefresh: _fetchMyNotifications,
                          child: ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _notifList.length,
                            itemBuilder: (context, index) {
                              final item = _notifList[index];
                              final schedDate = _parseTz(item['scheduled_at']);
                              final remainingDays = schedDate.difference(DateTime.now()).inDays;
                              final isManual = item['isManual'] == true;

                              Color borderColor = isManual ? Colors.blue.shade200 : Colors.red.shade200;
                              Color iconColor = isManual ? Colors.blue : Colors.red.shade400;
                              IconData iconData = isManual ? Icons.event_note : Icons.warning_rounded;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: borderColor),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item['title'] ?? 'Pengingat',
                                            style: GoogleFonts.plusJakartaSans(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                              color: iconColor,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (item['message'] != null)
                                            Text(
                                              item['message'],
                                              style: const TextStyle(fontSize: 14),
                                            ),
                                          const SizedBox(height: 4),
                                          Text(
                                            remainingDays < 0
                                                ? "Lewat ${remainingDays.abs()} hari"
                                                : remainingDays == 0
                                                    ? "Hari Ini - ${schedDate.hour.toString().padLeft(2, '0')}:${schedDate.minute.toString().padLeft(2, '0')}"
                                                    : "$remainingDays hari lagi",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: remainingDays < 0 ? Colors.red.shade700 : Colors.grey[600],
                                              fontWeight: remainingDays < 0 ? FontWeight.bold : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Icon(iconData, color: iconColor),
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