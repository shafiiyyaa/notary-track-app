import '../model/profile_model.dart';
import '../view/profile_view.dart';

class ProfilePresenter {
  final ProfileViewContract _view;
  ProfilePresenter(this._view);

  void loadProfile() {
    // Simulasi data dari model profil
    final data = ProfileModel(
      name: "Alexandra Saja ya",
      email: "alexandrasajayap@gmail.com",
      avatarUrl: "https://i.pravatar.cc/300", 
    );
    _view.displayProfileData(data);
  }
}