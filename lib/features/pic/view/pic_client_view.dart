// lib/features/pic/view/pic_client_view.dart
//
// Satu contract aja buat PicScreen, gantiin PicViewContract + ClientViewContract.

import '../model/pic_client_model.dart';

abstract class PicClientViewContract {
  void showLoading();
  void hideLoading();
  void onStaffLoaded(List<StaffModel> staffList);
  void onClientsLoaded(List<ClientModel> clientList);
  void onActionSuccess(String message);
  void onError(String message);
}