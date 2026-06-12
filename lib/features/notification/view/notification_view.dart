import '../model/notification_model.dart';

abstract class NotificationViewContract {
  void displayNotifications(List<NotificationModel> list);
}