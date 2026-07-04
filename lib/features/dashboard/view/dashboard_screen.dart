import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/constants.dart';
import '../model/dashboard_model.dart';
import '../presenter/dashboard_presenter.dart';
import 'dashboard_view.dart';
import '../../profile/view/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeViewContract {
  late HomePresenter _presenter;
  int _totalDocs = 0;
  int _completedDocs = 0;
  int _deadlineDocs = 0;
  String _username = "Admin";
  String? _avatarUrl; // <-- tampung URL foto profil, null kalau belum ada

  @override
  void onUserLoaded(String username) {
    setState(() {
      _username = username;
    });
  }

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter(this);
    _presenter.fetchDashboardSummary();
    _presenter.fetchDeadlineDocuments();
    _presenter.fetchUser();
  }

  @override
  void onSummaryLoaded(DashboardSummary summary) {
    setState(() {
      _totalDocs = summary.totalDocuments;
      _completedDocs = summary.completedDocuments;
      _deadlineDocs = summary.totalDeadlines;
    });
  }

  List<DeadlineItem> _deadlineList = [];

  @override
  void onDeadlineLoaded(List<DeadlineItem> deadlines) {
    setState(() {
      _deadlineList = deadlines;
    });
  }

  @override
  void onSummaryError(String message) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Halo,  $_username!',
                        style: GoogleFonts.comfortaa(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Aplikasi Pemantauan Dokumen Notaris',
                        style: TextStyle(
                          color: Theme.of(
                            context,
                          ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ProfileScreen(),
                        ),
                      ).then((_) {
                        // refresh data profil (nama/foto) kalau habis diedit
                        _presenter.fetchUser();
                      });
                    },
                    child: CircleAvatar(
                      radius: 24,
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      backgroundImage: _avatarUrl != null
                          ? NetworkImage(_avatarUrl!)
                          : null,
                      child: _avatarUrl == null
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      "Total Dokumen",
                      "$_totalDocs",
                      Icons.description_outlined,
                      Theme.of(context).cardColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildSummaryCard(
                      context,
                      "Jumlah Deadline",
                      "$_deadlineDocs",
                      Icons.calendar_month_outlined,
                      Theme.of(context).cardColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildWideSummaryCard(
                context,
                "Dokumen Selesai",
                "$_completedDocs",
                Icons.assignment_turned_in_outlined,
                Theme.of(context).cardColor.withValues(alpha: 0.7),
              ),
              const SizedBox(height: 32),
              Text(
                'Deadline Mendatang',
                style: GoogleFonts.comfortaa(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),
              const SizedBox(height: 16),
              ..._deadlineList.map(
                (item) => _buildDeadlineItem(
                  context,
                  item.clientName,
                  item.remainingDays == 0
                      ? "Deadline Hari Ini (${item.documentType})"
                      : item.remainingDays == 1
                      ? "Deadline Besok (${item.documentType})"
                      : "Deadline ${item.remainingDays} Hari Lagi (${item.documentType})",
                  "${item.deadline.day}/${item.deadline.month}/${item.deadline.year}",
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              Icon(icon, color: Theme.of(context).textTheme.bodyLarge?.color),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWideSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          Icon(icon, size: 36, color: Theme.of(context).textTheme.bodyLarge?.color),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(
    BuildContext context,
    String title,
    String desc,
    String date,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(width: 6, height: 40, color: AppColors.statusBelumProses),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                Text(
                  desc,
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.color?.withOpacity(0.6),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            date,
            style: const TextStyle(
              color: AppColors.statusBelumProses,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}