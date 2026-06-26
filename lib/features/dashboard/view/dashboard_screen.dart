import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/constants.dart';
import '../model/dashboard_model.dart';
import '../presenter/dashboard_presenter.dart';
import 'dashboard_view.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> implements HomeViewContract {
  late HomePresenter _presenter;
  int _totalDocs = 0;
  int _completedDocs = 0;
  String _username = "Admin";

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
  }

  @override
  void onSummaryLoaded(DashboardSummary summary) {
    setState(() {
      _totalDocs = summary.totalDocuments;
      _completedDocs = summary.completedDocuments;
    });
  }

  @override
  void onSummaryError(String message) {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                      Text('Halo,  $_username!', style: GoogleFonts.comfortaa(fontSize: 26, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text('Aplikasi Pemantauan Dokumen Notaris', style: TextStyle(color: Colors.black54)),
                    ],
                  ),
                  const CircleAvatar(radius: 24, backgroundColor: AppColors.primaryBlue, child: Icon(Icons.person, color: Colors.white))
                ],
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(child: _buildSummaryCard("Total Dokumen", "$_totalDocs", Icons.description_outlined, AppColors.cardBlueLight)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildSummaryCard("Jumlah Deadline", "5", Icons.calendar_month_outlined, AppColors.cardBlueDark)),
                ],
              ),
              const SizedBox(height: 16),
              _buildWideSummaryCard("Dokumen Selesai", "$_completedDocs", Icons.assignment_turned_in_outlined, AppColors.cardBlueLight.withValues(alpha: 0.7)),
              const SizedBox(height: 32),
              Text('Deadline Mendatang', style: GoogleFonts.comfortaa(fontSize: 22, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _buildDeadlineItem("PT. Bangkit Sendiri", "Deadline: 2 Hari lagi (AJB)", "10 Juni 2026"),
              _buildDeadlineItem("Bpk. Rahmat Aji", "Deadline: 5 Hari lagi (SHM)", "13 Juni 2026"),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Icon(icon)]),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildWideSummaryCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 8), Text(value, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))]),
        Icon(icon, size: 36),
      ]),
    );
  }

  Widget _buildDeadlineItem(String title, String desc, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(children: [
        Container(width: 6, height: 40, color: AppColors.statusBelumProses),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold)), Text(desc, style: const TextStyle(color: Colors.black54, fontSize: 12))])),
        Text(date, style: const TextStyle(color: AppColors.statusBelumProses, fontWeight: FontWeight.bold, fontSize: 12)),
      ]),
    );
  }
}