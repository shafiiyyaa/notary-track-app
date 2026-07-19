import 'package:shared_preferences/shared_preferences.dart';
import '../model/profile_model.dart';
import '../view/profile_view.dart';

class ProfilePresenter {
  final ProfileViewContract _view;

  ProfilePresenter(this._view);

  void loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final name = prefs.getString('user_name') ?? 'User';
    final role = prefs.getString('user_role') ?? '';

    final profile = ProfileModel(name: name, email: '', avatarUrl: '', role: role);
    _view.displayProfileData(profile);
  }
}