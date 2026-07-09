import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  String _username = "Admin";
  DashboardSummary? _summary;
  List<DeadlineItem> _deadlineList = [];
  final _rupiah = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter(this);
    _presenter.fetchDashboardSummary();
    _presenter.fetchDeadlineDocuments();
    _presenter.fetchUser();
  }

  @override
  void onUserLoaded(String username) => setState(() => _username = username);

  @override
  void onSummaryLoaded(DashboardSummary summary) => setState(() => _summary = summary);

  @override
  void onDeadlineLoaded(List<DeadlineItem> deadlines) =>
      setState(() => _deadlineList = deadlines);

  @override
  void onSummaryError(String message) {}

  @override
  Widget build(BuildContext context) {
    final summary = _summary;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: summary == null
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).textTheme.titleLarge?.color,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Monitoring Pekerjaan Kantor Notaris/PPAT',
                              style: TextStyle(
                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => const ProfileScreen()),
                            ).then((_) => _presenter.fetchUser());
                          },
                          child: CircleAvatar(
                            radius: 22,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: const Icon(Icons.person, color: Colors.white),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.6,
                      children: [
                        _statCard(context, "Total Masuk", "${summary.totalDocuments}",
                            Icons.inbox_outlined, Theme.of(context).colorScheme.primary),
                        _statCard(context, "Aktif", "${summary.aktif}",
                            Icons.settings_outlined, AppColors.statusDiproses),
                        _statCard(context, "Selesai", "${summary.selesai}",
                            Icons.check_circle_outline, AppColors.statusSelesai),
                        _statCard(context, "Tertunda", "${summary.tertunda}",
                            Icons.pause_circle_outline, AppColors.statusTertunda),
                        _statCard(context, "Batal", "${summary.batal}",
                            Icons.cancel_outlined, AppColors.statusBatal),
                        _statCard(context, "Terlambat", "${summary.terlambat}",
                            Icons.error_outline, AppColors.statusBelumProses),
                      ],
                    ),

                    const SizedBox(height: 28),
                    Text(
                      "Keuangan & Progress",
                      style: GoogleFonts.comfortaa(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _financeCard(context, "Total Nilai Jasa", summary.totalNilaiJasa,
                        Theme.of(context).colorScheme.primary),
                    const SizedBox(height: 10),
                    _financeCard(context, "Lunas", summary.totalLunas, AppColors.statusSelesai),
                    const SizedBox(height: 10),
                    _financeCard(context, "Belum Lunas", summary.totalBelumLunas, AppColors.statusBelumProses),

                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("Progress Keseluruhan",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).textTheme.bodyLarge?.color)),
                              Text("${summary.progressPercent.toStringAsFixed(0)}%",
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).colorScheme.primary)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: summary.progressPercent / 100,
                              minHeight: 10,
                              backgroundColor: Theme.of(context).dividerColor,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),
                    Text(
                      "Statistik",
                      style: GoogleFonts.comfortaa(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _buildStatusPieChart(context, summary),
                    const SizedBox(height: 20),
                    _buildCategoryBarChart(context, summary),

                    const SizedBox(height: 28),
                    Text(
                      'Deadline Mendatang',
                      style: GoogleFonts.comfortaa(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).textTheme.titleLarge?.color,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (_deadlineList.isEmpty)
                      Text(
                        'Tidak ada deadline mendatang',
                        style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                      )
                    else
                      ..._deadlineList.map((item) => _buildDeadlineItem(
                            context,
                            item.clientName,
                            item.remainingDays < 0
                                ? "Terlambat ${item.remainingDays.abs()} Hari (${item.documentType})"
                                : item.remainingDays == 0
                                    ? "Deadline Hari Ini (${item.documentType})"
                                    : item.remainingDays == 1
                                        ? "Deadline Besok (${item.documentType})"
                                        : "Deadline ${item.remainingDays} Hari Lagi (${item.documentType})",
                            "${item.deadline.day}/${item.deadline.month}/${item.deadline.year}",
                          )),

                    const SizedBox(height: 80),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _statCard(BuildContext context, String title, String value, IconData icon, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                  ),
                ),
              ),
              Icon(icon, size: 18, color: accent),
            ],
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _financeCard(BuildContext context, String title, double value, Color accent) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
        border: Border(left: BorderSide(color: accent, width: 4)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title,
              style: TextStyle(
                  fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyMedium?.color)),
          Text(_rupiah.format(value),
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accent)),
        ],
      ),
    );
  }

  Widget _buildStatusPieChart(BuildContext context, DashboardSummary summary) {
    if (summary.statusComposition.isEmpty || summary.totalDocuments == 0) {
      return _emptyChartBox(context, "Komposisi Status");
    }

    final colorMap = {
      'Belum Diproses': AppColors.statusBelumProses,
      'Diproses': AppColors.statusDiproses,
      'Tertunda': AppColors.statusTertunda,
      'Batal': AppColors.statusBatal,
      'Selesai': AppColors.statusSelesai,
    };

    final entries = summary.statusComposition.entries.toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Komposisi Status",
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 16),
          SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 40,
                sections: entries.map((e) {
                  final color = colorMap[e.key] ?? Colors.grey;
                  return PieChartSectionData(
                    value: e.value.toDouble(),
                    color: color,
                    title: '${e.value}',
                    radius: 55,
                    titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 12,
            runSpacing: 8,
            children: entries.map((e) {
              final color = colorMap[e.key] ?? Colors.grey;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(e.key, style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color)),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBarChart(BuildContext context, DashboardSummary summary) {
    if (summary.categoryComposition.isEmpty) {
      return _emptyChartBox(context, "Pekerjaan per Kategori");
    }

    final entries = summary.categoryComposition.entries.toList();
    final maxY = entries.map((e) => e.value).reduce((a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Pekerjaan per Kategori",
              style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: BarChart(
              BarChartData(
                maxY: maxY + 1,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 24)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= entries.length) return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            entries[index].key,
                            style: TextStyle(fontSize: 10, color: Theme.of(context).textTheme.bodyMedium?.color),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: const FlGridData(show: false),
                barGroups: List.generate(entries.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entries[i].value.toDouble(),
                        color: Theme.of(context).colorScheme.primary,
                        width: 22,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _emptyChartBox(BuildContext context, String title) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
          const SizedBox(height: 20),
          Center(
            child: Text('Belum ada data',
                style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5))),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDeadlineItem(BuildContext context, String title, String desc, String date) {
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
                Text(title,
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color)),
                Text(desc,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6), fontSize: 12)),
              ],
            ),
          ),
          Text(date,
              style: const TextStyle(
                  color: AppColors.statusBelumProses, fontWeight: FontWeight.bold, fontSize: 12)),
        ],
      ),
    );
  }
}