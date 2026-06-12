import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/constants.dart';
import '../model/history_model.dart';
import '../presenter/history_presenter.dart';
import 'history_view.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    implements HistoryViewContract {
  late HistoryPresenter _presenter;
  List<HistoryModel> _historyList = [];

  @override
  void initState() {
    super.initState();
    _presenter = HistoryPresenter(this);
    _presenter.loadHistory();
  }

  @override
  void displayHistory(List<HistoryModel> list) {
    setState(() {
      _historyList = list;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 30),
            Text(
              'Riwayat',
              style: GoogleFonts.comfortaa(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            // Header Tabel Sesuai Gambar Berkas Kontrak
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: Text("Status", style: _headerStyle()),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("Waktu", style: _headerStyle()),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text("Dokumen", style: _headerStyle()),
                  ),
                ],
              ),
            ),
            const Divider(thickness: 1, height: 30, indent: 16, endIndent: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _historyList.length,
                itemBuilder: (context, index) {
                  final item = _historyList[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF2E8B57,
                                  ), // Hijau seagreen khas rancanganmu
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  item.status,
                                  style: GoogleFonts.plusJakartaSans(
                                    color: Colors.white,
                                    fontSize: 11,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                "Staff : ${item.staff}",
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 10,
                                  color: Colors.black54,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.waktu,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.doc,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle() =>
      GoogleFonts.plusJakartaSans(fontSize: 16, fontWeight: FontWeight.bold);
}
