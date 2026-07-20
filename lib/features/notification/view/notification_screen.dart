import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../model/notification_model.dart';
import '../presenter/notification_presenter.dart';
import '../services/notification_service.dart';
import 'notification_view.dart';
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

  // Fungsi untuk tes notif 5 detik dari sekarang
  Future<void> _testNotifNow() async {
    await NotificationService().scheduleDeadlineNotification(
      id: 99999,
      title: "TES NOTIFIKASI 🔔",
      body: "Jika ini muncul, berarti notifikasi aplikasi Anda berfungsi!",
      scheduledDate: DateTime.now().add(
        const Duration(seconds: 5),
      ), // 5 detik dari sekarang
      isFullScreenPopup: true,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          "Notif tes dijadwalkan 5 detik lagi... Jangan tutup aplikasi!",
        ),
      ),
    );
  }

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
    _loadData();
  }

  // Fungsi untuk menampilkan pop-up detail saat card diklik
  void _showDetailBottomSheet(NotificationModel item) {
    final formatTanggal = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');
    final formatJam = DateFormat('HH:mm');

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[400],
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Icon(
                    item.isManual ? Icons.event_note : Icons.warning_rounded,
                    color: item.isManual ? Colors.blue : Colors.red,
                    size: 30,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.title,
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const Divider(height: 30),
              _buildDetailRow("Klien / Terkait", item.clientName),
              const SizedBox(height: 12),
              _buildDetailRow(
                "Tanggal",
                formatTanggal.format(item.scheduledDate),
              ),
              const SizedBox(height: 12),
              _buildDetailRow("Jam", formatJam.format(item.scheduledDate)),
              const SizedBox(height: 12),
              _buildDetailRow(
                "Status",
                item.remainingDays == 0
                    ? "Hari Ini"
                    : "${item.remainingDays} hari lagi",
              ),

              if (item.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                _buildDetailRow("Catatan", item.description),
              ],

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    "Baik, saya ingat",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
        ),
        const Text(" : "),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
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

            // TOMBOL TES NOTIFIKASI
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8,
              ),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.primary,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  onPressed: _testNotifNow,
                  icon: const Icon(Icons.notifications_active),
                  label: const Text("Tes Notifikasi (5 Detik)"),
                ),
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
                          Color borderColor = item.isManual
                              ? Colors.blue.shade200
                              : Colors.red.shade200;

                          return GestureDetector(
                            onTap: () => _showDetailBottomSheet(item),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: borderColor),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.title,
                                          style: GoogleFonts.plusJakartaSans(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                            color: item.isManual
                                                ? Colors.blue
                                                : Colors.red,
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
                                              ? "Hari Ini - ${item.scheduledDate.hour.toString().padLeft(2, '0')}:${item.scheduledDate.minute.toString().padLeft(2, '0')}"
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
                                    item.isManual
                                        ? Icons.event_note
                                        : Icons.warning_rounded,
                                    color: item.isManual
                                        ? Colors.blue
                                        : Colors.red.shade400,
                                  ),
                                ],
                              ),
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
