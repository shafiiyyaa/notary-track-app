import '../model/client_model.dart';

abstract class ClientViewContract {
  void showLoading();
  void hideLoading();
  void onClientsLoaded(List<ClientModel> clients);
  void onActionSuccess(String message);
  void onError(String message);
}