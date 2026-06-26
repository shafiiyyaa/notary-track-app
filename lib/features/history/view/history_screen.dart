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

  bool _loading = true;

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
  void showLoading() {
    setState(() {
      _loading = true;
    });
  }

  @override
  void hideLoading() {
    setState(() {
      _loading = false;
    });
  }

  @override
  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  const SizedBox(height: 30),

                  Text(
                    "Riwayat",
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 25),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Expanded(
                            flex: 2,
                            child: Text("Status",
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 3,
                            child: Text("Waktu",
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold))),
                        Expanded(
                            flex: 3,
                            child: Text("Dokumen",
                                style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold))),
                      ],
                    ),
                  ),

                  const Divider(),

                  Expanded(
                    child: ListView.builder(
                      itemCount: _historyList.length,
                      itemBuilder: (_, index) {
                        final item = _historyList[index];

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: Colors.green,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        item.status,
                                        style: const TextStyle(
                                            color: Colors.white),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Staff : ${item.staff}",
                                      style: const TextStyle(fontSize: 11),
                                    )
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(item.waktu),
                              ),
                              Expanded(
                                flex: 3,
                                child: Text(item.doc),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  )
                ],
              ),
      ),
    );
  }
}