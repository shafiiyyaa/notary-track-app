import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../model/profile_model.dart';
import '../presenter/profile.presenter.dart';
import 'profile_view.dart';
import '../about_app/view/about_app_screen.dart';
import '../../auth/login/view/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    implements ProfileViewContract {
  late ProfilePresenter _presenter;
  ProfileModel? _profile;

  @override
  void initState() {
    super.initState();
    _presenter = ProfilePresenter(this);
    _presenter.loadProfile();
  }

  @override
  void displayProfileData(ProfileModel data) {
    setState(() {
      _profile = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: _profile == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Text(
                        "Akun Saya",
                        style: GoogleFonts.comfortaa(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.titleLarge?.color,
                        ),
                      ),

                      const SizedBox(height: 30),

                      Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 70,
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Image.asset(
                                "assets/images/logo.png",
                                fit: BoxFit.contain,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),   

                      const SizedBox(height: 20),

                      Text(
                        _profile!.name,
                        style: GoogleFonts.comfortaa(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),

                      const SizedBox(height: 5),

                      Text(
                        _profile!.email,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                        ),
                      ),

                      const SizedBox(height: 50),

                      _menuTile(
                        context,
                        Icons.lock,
                        "Tentang Aplikasi",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const AboutAppScreen(),
                            ),
                          );
                        },
                      ),

                      _menuTile(
                        context,
                        Icons.logout,
                        "Keluar",
                        () async {
                          await Supabase.instance.client.auth.signOut();
                          if (!mounted) return;
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(builder: (_) => const LoginScreen()),
                            (route) => false,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _menuTile(
    BuildContext context,
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(
          title,
          style: GoogleFonts.comfortaa(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).textTheme.bodyLarge?.color,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
        onTap: onTap,
      ),
    );
  }
}