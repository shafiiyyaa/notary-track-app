import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../../theme/theme_provider.dart';
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
                          const CircleAvatar(
                            radius: 70,
                            backgroundImage: AssetImage(
                              "assets/images/0e9da6a3619b0ce0eea22849978221c2.jpg",
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              // Nanti di sini kita buka galeri HP
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 18,
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

                      _buildThemeTile(context),

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

  Widget _buildThemeTile(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: SwitchListTile(
            secondary: Icon(
              themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
              color: Theme.of(context).colorScheme.primary,
            ),
            title: Text(
              "Dark Mode",
              style: GoogleFonts.comfortaa(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            value: themeProvider.isDark,
            onChanged: (_) => themeProvider.toggleTheme(),
          ),
        );
      },
    );
  }
}