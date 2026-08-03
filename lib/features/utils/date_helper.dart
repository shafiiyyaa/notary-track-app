
/// Helper terpusat untuk parsing tanggal/deadline dari Supabase.
///
/// KENAPA INI ADA:
/// Kolom deadline di Supabase kemungkinan bertipe `timestamptz`, dan saat
/// disimpan dari Flutter, jam WIB yang diinput (misal 21:45) tersimpan
/// dengan penanda UTC (contoh: "2026-08-02T21:45:00.000Z") tanpa benar-benar
/// dikonversi. Kalau string ini di-parse apa adanya dengan `DateTime.parse`,
/// Dart akan menganggap 21:45 itu jam UTC, yang kalau dikonversi ke waktu
/// lokal (WIB) jadi 04:45 keesokan harinya — geser +7 jam dari yang
/// dimaksud.
///
/// `parseDeadline()` mendeteksi penanda UTC ('Z' atau '+00:00') lalu
/// mengambil angka jam-menit-detiknya apa adanya dan memperlakukannya
/// sebagai waktu lokal (WIB), tanpa konversi timezone. Pakai fungsi ini
/// di SEMUA tempat yang butuh baca/bandingkan deadline, supaya hasilnya
/// selalu konsisten (dashboard, daftar pekerjaan, detail dokumen, dst).
///
/// Kalau suatu saat cara penyimpanan deadline di source diperbaiki
/// (insert dengan offset +07:00 yang benar), cukup ubah logika di file
/// ini saja — tidak perlu ubah satu-satu di setiap model/presenter.
class DateHelper {
  DateHelper._();

  /// Parse string deadline dari Supabase menjadi [DateTime] lokal (WIB),
  /// tanpa geser timezone. Mengembalikan null kalau string kosong/invalid.
  static DateTime? parseDeadline(String? input) {
    if (input == null || input.isEmpty) return null;

    try {
      // Kalau formatnya pakai spasi ("2026-08-02 21:45:00"), ganti jadi
      // format ISO ("2026-08-02T21:45:00") supaya bisa di-parse.
      final cleanInput = input.contains(' ')
          ? input.replaceAll(' ', 'T')
          : input;

      final dt = DateTime.parse(cleanInput);

      // Kalau ada penanda UTC, buang tanpa konversi -> anggap jam WIB asli.
      if (cleanInput.contains('Z') || cleanInput.contains('+00:00')) {
        return DateTime(dt.year, dt.month, dt.day, dt.hour, dt.minute, dt.second);
      }

      return dt;
    } catch (e) {
      return DateTime.tryParse(input);
    }
  }

  /// Cek apakah sebuah deadline sudah lewat dari sekarang.
  /// [status] opsional — kalau statusnya 'Selesai' atau 'Batal', selalu
  /// dianggap tidak terlambat (dokumen sudah tidak aktif).
  static bool isLate(String? deadline, {String? status}) {
    if (status == 'Selesai' || status == 'Batal') return false;

    final dt = parseDeadline(deadline);
    if (dt == null) return false;

    return dt.isBefore(DateTime.now());
  }

  /// Hitung selisih hari antara deadline dan hari ini (dibulatkan ke hari,
  /// bukan jam), berguna untuk badge "X hari lagi" / "X hari lewat".
  /// Positif = masih ada waktu, negatif/nol = sudah lewat atau jatuh hari ini.
  static int? remainingDays(String? deadline) {
    final dt = parseDeadline(deadline);
    if (dt == null) return null;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final deadlineDate = DateTime(dt.year, dt.month, dt.day);

    return deadlineDate.difference(today).inDays;
  }
}