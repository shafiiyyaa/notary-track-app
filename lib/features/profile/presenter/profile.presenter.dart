import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/profile_model.dart';
import '../view/profile_view.dart';

class ProfilePresenter {
  final ProfileViewContract _view;

  ProfilePresenter(this._view);

  void loadProfile() {
    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) return;

    final profile = ProfileModel(
      name: user.userMetadata?['username'] ?? 'User',
      email: user.email ?? '',
      avatarUrl: '',
    );

    _view.displayProfileData(profile);
  }
}