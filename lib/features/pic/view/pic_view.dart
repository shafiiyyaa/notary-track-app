import '../model/staff_model.dart';

abstract class PicViewContract {
  void showLoading();
  void hideLoading();
  void onStaffLoaded(List<StaffModel> staffList);
  void onActionSuccess(String message);
  void onError(String message);
}