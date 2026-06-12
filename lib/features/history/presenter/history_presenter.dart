import '../model/history_model.dart';
import '../view/history_view.dart';

class HistoryPresenter {
  final HistoryViewContract _view;
  HistoryPresenter(this._view);

  void loadHistory() {
    final list = [
      HistoryModel(status: "Selesai", staff: "Tri", waktu: "03-Maret-2026", doc: "Balik Nama AJB"),
      HistoryModel(status: "Selesai", staff: "Alex", waktu: "30-Maret-2026", doc: "Pemecahan Sertifikat"),
      HistoryModel(status: "Selesai", staff: "Dwii", waktu: "03-April-2026", doc: "Pendirian Yayasan"),
      HistoryModel(status: "Selesai", staff: "Lea", waktu: "30-April-2026", doc: "Surat Hutang Piutang"),
      HistoryModel(status: "Selesai", staff: "Tri", waktu: "03-Mei-2026", doc: "Balik Nama Akta"),
    ];
    _view.displayHistory(list);
  }
}