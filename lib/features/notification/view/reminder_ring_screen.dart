import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class ReminderRingScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String clientName;
  final String location;
  final String scheduledDateIso;

  const ReminderRingScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.clientName,
    required this.location,
    required this.scheduledDateIso,
  });

  @override
  Widget build(BuildContext context) {
    DateTime? scheduledDate;
    try {
      scheduledDate = DateTime.parse(scheduledDateIso).toLocal();
    } catch (_) {
      scheduledDate = null;
    }

    final formatTanggal = scheduledDate != null
        ? DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(scheduledDate)
        : '-';
    final formatJam =
        scheduledDate != null ? DateFormat('HH:mm').format(scheduledDate) : '-';

    return PopScope(
      canPop: false, // cegah back gesture/tombol tanpa sadar
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.primary,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Icon(Icons.notifications_active,
                    color: Colors.white, size: 90),
                const SizedBox(height: 24),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.comfortaa(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                if (subtitle.isNotEmpty)
                  Text(
                    subtitle,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                  ),
                const SizedBox(height: 40),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow(Icons.person, 'Klien', clientName),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        _buildRow(Icons.location_on, 'Lokasi', location),
                      ],
                      const SizedBox(height: 14),
                      _buildRow(Icons.calendar_today, 'Tanggal', formatTanggal),
                      const SizedBox(height: 14),
                      _buildRow(Icons.access_time, 'Jam', formatJam),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Baik, saya ingat',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey[700]),
        const SizedBox(width: 10),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700]),
          ),
        ),
        const Text(' : '),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}