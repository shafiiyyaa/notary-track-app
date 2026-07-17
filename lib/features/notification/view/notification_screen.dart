import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../model/notification_model.dart';
import '../presenter/notification_presenter.dart';
import 'notification_view.dart';
// Import file AddNotificationSheet yang kita buat di step sebelumnya
import 'add_notification_sheet.dart'; 

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    implements NotificationViewContract {
  late NotificationPresenter _presenter;
  List<NotificationModel> _notifList = [];

  @override
  void initState() {
    super.initState();
    _presenter = NotificationPresenter(this);
    _loadData();
  }

  Future<void> _loadData() async {
    await _presenter.loadNotifications();
  }

  @override
  void displayNotifications(List<NotificationModel> list) {
    setState(() {
      _notifList = list;
    });
  }

  // Fungsi untuk membuka bottom sheet tambah notifikasi
  Future<void> _openAddNotifSheet() async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const AddNotificationSheet(),
    );
    // Setelah sheet ditutup, refresh list notifikasi
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddNotifSheet,
        backgroundColor: Theme.of(context).colorScheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  SizedBox(
                    width: 40,
                    child: IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  Text(
                    'Notifikasi',
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Icon(Icons.notifications_active_outlined, size: 30),
                ],
              ),
            ),
            Expanded(
              child: _notifList.isEmpty
                  ? const Center(child: Text("Tidak ada notifikasi aktif"))
                  : RefreshIndicator(
                      onRefresh: _loadData,
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _notifList.length,
                        itemBuilder: (context, index) {
                          final item = _notifList[index];
                          
                          // Tentukan warna border berdasarkan jenis notif
                          Color borderColor = item.isManual ? Colors.blue.shade200 : Colors.red.shade200;
                          
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
                                        item.title,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: item.isManual ? Colors.blue : Colors.red,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.clientName,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        item.remainingDays == 0
                                            ? "Hari Ini - ${item.scheduledDate.hour.toString().padLeft(2,'0')}:${item.scheduledDate.minute.toString().padLeft(2,'0')}"
                                            : "${item.remainingDays} hari lagi",
                                        style: GoogleFonts.plusJakartaSans(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Icon(
                                  item.isManual ? Icons.event_note : Icons.warning_rounded,
                                  color: item.isManual ? Colors.blue : Colors.red.shade400,
                                ),
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