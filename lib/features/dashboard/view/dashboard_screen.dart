import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
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
  DashboardSummary? _summary;
  List<PriorityDeadlineItem> _mendekati = [];
  List<PriorityDeadlineItem> _terlambatList = [];
  List<UnpaidItem> _belumLunasList = [];
  bool _isRefreshing = false;
  final _rupiah = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  @override
  void initState() {
    super.initState();
    _presenter = HomePresenter(this);
    _loadData();
  }

  void _loadData() {
    _presenter.fetchDashboardSummary();
    _presenter.fetchPriorityData();
  }

  Future<void> _handleRefresh() async {
    setState(() => _isRefreshing = true);
    _loadData();
    // beri jeda kecil biar animasi ikon refresh kelihatan, bukan cuma kedip
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) setState(() => _isRefreshing = false);
  }

  @override
  void onSummaryLoaded(DashboardSummary summary) =>
      setState(() => _summary = summary);

  @override
  void onPriorityLoaded(
    List<PriorityDeadlineItem> mendekati,
    List<PriorityDeadlineItem> terlambat,
    List<UnpaidItem> belumLunas,
  ) {
    setState(() {
      _mendekati = mendekati;
      _terlambatList = terlambat;
      _belumLunasList = belumLunas;
    });
  }

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
            : LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 800;
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(context),
                        const SizedBox(height: 18),
                        isWide
                            ? _buildWideLayout(context, summary)
                            : _buildNarrowLayout(context, summary),
                        const SizedBox(height: 80),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final today = DateFormat('dd/MM/yyyy').format(DateTime.now());
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            padding: const EdgeInsets.all(6),
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
                  "Monitoring Pekerjaan Kantor Notaris/PPAT — $today",
                  style: const TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _isRefreshing ? null : _handleRefresh,
            icon: _isRefreshing
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildNarrowLayout(BuildContext context, DashboardSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatGrid(context, summary, crossAxisCount: 2),
        const SizedBox(height: 20),
        _buildFinanceSection(context, summary),
        const SizedBox(height: 20),
        _buildStatisticSection(context, summary),
        const SizedBox(height: 20),
        _buildPrioritySection(context),
      ],
    );
  }

  Widget _buildWideLayout(BuildContext context, DashboardSummary summary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatGrid(context, summary, crossAxisCount: 3),
              const SizedBox(height: 20),
              _buildFinanceSection(context, summary),
            ],
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatisticSection(context, summary),
              const SizedBox(height: 20),
              _buildPrioritySection(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatGrid(
    BuildContext context,
    DashboardSummary summary, {
    required int crossAxisCount,
  }) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 2.6,
      children: [
        _statCard(
          context,
          "Total Masuk",
          "${summary.totalDocuments}",
          Icons.inbox_outlined,
          Theme.of(context).colorScheme.primary,
        ),
        _statCard(
          context,
          "Aktif",
          "${summary.aktif}",
          Icons.settings_outlined,
          AppColors.statusDiproses,
        ),
        _statCard(
          context,
          "Selesai",
          "${summary.selesai}",
          Icons.check_circle_outline,
          AppColors.statusSelesai,
        ),
        _statCard(
          context,
          "Tertunda",
          "${summary.tertunda}",
          Icons.pause_circle_outline,
          AppColors.statusTertunda,
        ),
        _statCard(
          context,
          "Batal",
          "${summary.batal}",
          Icons.cancel_outlined,
          AppColors.statusBatal,
        ),
        _statCard(
          context,
          "Terlambat",
          "${summary.terlambat}",
          Icons.error_outline,
          AppColors.statusBelumProses,
        ),
      ],
    );
  }

  Widget _buildFinanceSection(BuildContext context, DashboardSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Keuangan & Progress",
          style: GoogleFonts.comfortaa(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        _financeCard(
          context,
          "Total Nilai Jasa",
          summary.totalNilaiJasa,
          Theme.of(context).colorScheme.primary,
        ),
        const SizedBox(height: 6),
        _financeCard(
          context,
          "Lunas",
          summary.totalLunas,
          AppColors.statusSelesai,
        ),
        const SizedBox(height: 6),
        _financeCard(
          context,
          "Belum Lunas",
          summary.totalBelumLunas,
          AppColors.statusBelumProses,
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Progress Keseluruhan",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  Text(
                    "${summary.progressPercent.toStringAsFixed(0)}%",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: summary.progressPercent / 100,
                  minHeight: 7,
                  backgroundColor: Theme.of(context).dividerColor,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticSection(
    BuildContext context,
    DashboardSummary summary,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Statistik",
          style: GoogleFonts.comfortaa(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        _buildStatusPieChart(context, summary),
        const SizedBox(height: 14),
        _buildCategoryBarChart(context, summary),
      ],
    );
  }

  Widget _buildPrioritySection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Prioritas & Perhatian",
          style: GoogleFonts.comfortaa(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 8),
        _priorityCard(
          context,
          "Mendekati Deadline (≤14 hari)",
          Icons.calendar_today,
          AppColors.statusDiproses,
          _mendekati.isEmpty
              ? null
              : _mendekati
                    .map(
                      (e) =>
                          "${e.clientName} • ${e.documentType} • ${e.remainingDays} hari lagi",
                    )
                    .toList(),
        ),
        const SizedBox(height: 10),
        _priorityCard(
          context,
          "Terlambat",
          Icons.error_outline,
          AppColors.statusBelumProses,
          _terlambatList.isEmpty
              ? null
              : _terlambatList
                    .map(
                      (e) =>
                          "${e.clientName} • ${e.documentType} • ${e.remainingDays.abs()} hari lewat",
                    )
                    .toList(),
        ),
        const SizedBox(height: 10),
        _priorityCard(
          context,
          "Belum Lunas",
          Icons.attach_money,
          AppColors.statusTertunda,
          _belumLunasList.isEmpty
              ? null
              : _belumLunasList
                    .map(
                      (e) =>
                          "${e.clientName} • ${e.documentType} • ${_rupiah.format(e.sisaTagihan)}",
                    )
                    .toList(),
        ),
      ],
    );
  }

  Widget _priorityCard(
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
          if (items == null)
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

  Widget _statCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
          Icon(icon, size: 14, color: accent),
        ],
      ),
    );
  }

  Widget _financeCard(
    BuildContext context,
    String title,
    double value,
    Color accent,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(10),
        border: Border(left: BorderSide(color: accent, width: 3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
          Text(
            _rupiah.format(value),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: accent,
            ),
          ),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Komposisi Status",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 2,
                centerSpaceRadius: 28,
                sections: entries.map((e) {
                  final color = colorMap[e.key] ?? Colors.grey;
                  return PieChartSectionData(
                    value: e.value.toDouble(),
                    color: color,
                    title: '${e.value}',
                    radius: 38,
                    titleStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 5,
            children: entries.map((e) {
              final color = colorMap[e.key] ?? Colors.grey;
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    e.key,
                    style: TextStyle(
                      fontSize: 10,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryBarChart(
    BuildContext context,
    DashboardSummary summary,
  ) {
    if (summary.categoryComposition.isEmpty) {
      return _emptyChartBox(context, "Pekerjaan per Jenis Dokumen");
    }

    final entries = summary.categoryComposition.entries.toList();
    final maxCount = entries
        .map((e) => e.value)
        .reduce((a, b) => a > b ? a : b);
    final interval = maxCount <= 5 ? 1.0 : (maxCount / 5).ceilToDouble();
    final maxY = ((maxCount / interval).ceil() * interval) + interval;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Pekerjaan per Jenis Dokumen",
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: BarChart(
              BarChartData(
                maxY: maxY,
                minY: 0,
                barTouchData: BarTouchData(enabled: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: interval,
                      getTitlesWidget: (value, meta) {
                        if (value % interval != 0) return const SizedBox();
                        return Text(
                          value.toInt().toString(),
                          style: TextStyle(
                            fontSize: 9,
                            color: Theme.of(
                              context,
                            ).textTheme.bodyMedium?.color,
                          ),
                        );
                      },
                    ),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= entries.length)
                          return const SizedBox();
                        return Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            entries[index].key,
                            style: TextStyle(
                              fontSize: 8,
                              color: Theme.of(
                                context,
                              ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(
                  show: true,
                  horizontalInterval: interval,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (value) => FlLine(
                    color: Theme.of(context).dividerColor,
                    strokeWidth: 1,
                  ),
                ),
                barGroups: List.generate(entries.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: entries[i].value.toDouble(),
                        color: Theme.of(context).colorScheme.primary,
                        width: 16,
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).textTheme.bodyLarge?.color,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Text(
              'Belum ada data',
              style: TextStyle(
                color: Theme.of(
                  context,
                ).textTheme.bodyMedium?.color?.withOpacity(0.5),
              ),
            ),
          ),
          const SizedBox(height: 14),
        ],
      ),
    );
  }
}
