import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ClientNotificationScreen extends StatefulWidget {
  const ClientNotificationScreen({super.key});

  @override
  State<ClientNotificationScreen> createState() => _ClientNotificationScreenState();
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

  Future<void> _fetchMyNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    final clientId = prefs.getString('user_id');

    try {
      final response = await _supabase
          .from('notifications')
          .select('id, title, message, scheduled_at')
          .eq('client_id', clientId!)
          .gte('scheduled_at', DateTime.now().toIso8601String())
          .order('scheduled_at', ascending: true);

      setState(() {
        _notifList = List<Map<String, dynamic>>.from(response);
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetch client notif: $e");
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
                  'Notifikasi Janji Temu',
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
                              final schedDate = DateTime.parse(item['scheduled_at']).toLocal();
                              final remainingDays = schedDate.difference(DateTime.now()).inDays;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).cardColor,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: Colors.blue.shade200),
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
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          if (item['message'] != null)
                                            Text(item['message'], style: const TextStyle(fontSize: 14)),
                                          const SizedBox(height: 4),
                                          Text(
                                            remainingDays == 0
                                                ? "Hari Ini - ${schedDate.hour.toString().padLeft(2,'0')}:${schedDate.minute.toString().padLeft(2,'0')}"
                                                : "${remainingDays} hari lagi",
                                            style: GoogleFonts.plusJakartaSans(
                                              fontSize: 12,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const Icon(Icons.event_note, color: Colors.blue),
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