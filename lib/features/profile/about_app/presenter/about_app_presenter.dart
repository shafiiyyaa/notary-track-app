import '../model/about_app_model.dart';
import '../view/about_app_view.dart';

class AboutAppPresenter {
  final AboutAppViewContract view;

  AboutAppPresenter(this.view);

  void loadData() {
    view.showData(
      AboutAppModel(
        appName: "Notary Track",
        version: "Versi 1.0.0",
        description:
            "Notary Track merupakan aplikasi manajemen dokumen yang dikembangkan untuk membantu proses administrasi pada Kantor Notaris dan PPAT Saptadi Setya Nugraha yang berlokasi di Karawang, Jawa Barat. Aplikasi ini hadir sebagai solusi atas proses pencatatan dan pemantauan dokumen yang sebelumnya masih dilakukan secara manual sehingga berpotensi menimbulkan kesalahan pencatatan, keterlambatan proses, maupun kesulitan dalam melacak perkembangan dokumen.\n\nMelalui Notary Track, seluruh proses administrasi dapat dilakukan secara lebih terstruktur dan efisien. Pengguna dapat mengelola data klien, mencatat jenis dokumen, mengatur biaya administrasi, memantau status pengerjaan dokumen, serta menerima pengingat terkait tenggat waktu penyelesaian. Seluruh informasi tersimpan secara terpusat sehingga memudahkan staf dalam melakukan pencarian data, memonitor progres pekerjaan, serta meningkatkan ketelitian dalam pengelolaan dokumen.\n\nAplikasi ini dirancang dengan antarmuka yang sederhana, mudah digunakan, serta disesuaikan dengan kebutuhan operasional kantor notaris. Dengan memanfaatkan sistem digital, Notary Track diharapkan mampu meningkatkan efektivitas pelayanan administrasi, mengurangi risiko kehilangan data, serta mendukung proses kerja yang lebih cepat, akurat, dan terdokumentasi dengan baik.",
      ),
    );
  }
}