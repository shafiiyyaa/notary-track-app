import '../model/notification_model.dart';
import '../view/notification_view.dart';

class NotificationPresenter {
  final NotificationViewContract _view;
  NotificationPresenter(this._view);

  void loadNotifications() {
    final list = [
      NotificationModel(title: "PT. Bangkit Sendiri", deadline: "2 Hari lagi (AJB)", date: "10 Mei 2026", isUrgent: false),
      NotificationModel(title: "PT. Besok makan apa", deadline: "2 Hari lagi (AJB)", date: "10 Mei 2026", isUrgent: false),
      NotificationModel(title: "Bpk. Rahmat Aji", deadline: "5 Hari lagi (SHM)", date: "13 Mei 2026", isUrgent: true),
      NotificationModel(title: "PT. Jatuh Bangun", deadline: "8 Hari lagi (CV)", date: "16 Mei 2026", isUrgent: false),
      NotificationModel(title: "Yayasan Apalah ya", deadline: "10 Hari lagi (CV)", date: "18 Mei 2026", isUrgent: false),
    ];
    _view.displayNotifications(list);
  }
}