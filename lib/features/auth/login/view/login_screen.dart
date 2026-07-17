import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../dashboard/main_navigation.dart';
import '../presenter/login_presenter.dart';
import '../view/login_view.dart';
import '../../register/view/register_screen.dart';
import '../../../client/client_navigation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    implements LoginViewContract {
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscureText = true;
  bool _isLoading = false;
  String _selectedRole = 'Staff';

  late LoginPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = LoginPresenter(this);
    _checkExistingSession();
  }

  Future<void> _checkExistingSession() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString('user_role');
    if (role != null && mounted) {
      if (role == 'Staff') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
      } else if (role == 'Klien') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClientNavigation()));
      }
    }
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onLoginSuccess(String role) {
    if (role == 'Staff') {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainNavigation()));
    } else {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const ClientNavigation()));
    }
  }

  @override
  void onLoginError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    String identifierLabel = _selectedRole == 'Staff' ? "Email" : "Username";
    IconData identifierIcon = _selectedRole == 'Staff' ? Icons.email_outlined : Icons.person_outline;
    TextInputType keyboardType = _selectedRole == 'Staff' ? TextInputType.emailAddress : TextInputType.text;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(
              context,
              title: "Selamat Datang",
              subtitle: "Masuk untuk melanjutkan pemantauan\ndokumen notaris Anda.",
            ),
            Transform.translate(
              offset: const Offset(0, -20),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Column(
                  children: [
                    _roleToggle(context),
                    const SizedBox(height: 24),

                    _buildFieldLabel(context, identifierLabel),
                    TextField(
                      controller: _identifierController,
                      keyboardType: keyboardType,
                      decoration: InputDecoration(
                        prefixIcon: Icon(identifierIcon),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    _buildFieldLabel(context, "Kata Sandi"),
                    TextField(
                      controller: _passwordController,
                      obscureText: _obscureText,
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                          onPressed: () => setState(() => _obscureText = !_obscureText),
                        ),
                        filled: true,
                        fillColor: Theme.of(context).cardColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () {
                                _presenter.performLogin(
                                  role: _selectedRole,
                                  identifier: _identifierController.text.trim(),
                                  password: _passwordController.text.trim(),
                                );
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Masuk",
                                style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                      ),
                    ),
                    const SizedBox(height: 20),

                    if (_selectedRole == 'Staff')
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Belum punya akun? ",
                              style: TextStyle(fontSize: 14, color: Theme.of(context).textTheme.bodyMedium?.color)),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen()),
                            ),
                            child: Text("Daftar",
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: primary)),
                          ),
                        ],
                      )
                    else
                      Text(
                        "Belum punya akun? Hubungi kantor notaris\nuntuk pembuatan akun klien.",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6)),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _roleToggle(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Container(
      width: 240,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: [
          Expanded(child: _roleOption(context, 'Staff', Icons.badge_outlined, primary)),
          Expanded(child: _roleOption(context, 'Klien', Icons.person_outline, primary)),
        ],
      ),
    );
  }

  Widget _roleOption(BuildContext context, String role, IconData icon, Color primary) {
    final isActive = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? primary : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 15, color: isActive ? Colors.white : Colors.grey),
            const SizedBox(width: 6),
            Text(
              role,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(BuildContext context, String label) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
    );
  }
}

Widget _buildHeader(BuildContext context, {required String title, required String subtitle}) {
  final primary = Theme.of(context).colorScheme.primary;
  return Container(
    width: double.infinity,
    height: 300,
    color: primary,
    child: Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(top: 20, left: -10, child: Icon(Icons.description_outlined, size: 70, color: Colors.white.withOpacity(0.08))),
        Positioned(top: 90, right: -20, child: Icon(Icons.edit_note, size: 100, color: Colors.white.withOpacity(0.08))),
        Positioned(bottom: 40, left: 30, child: Icon(Icons.verified_outlined, size: 50, color: Colors.white.withOpacity(0.10))),
        Positioned(bottom: -10, right: 40, child: Icon(Icons.gavel_outlined, size: 60, color: Colors.white.withOpacity(0.08))),
        Positioned(top: 130, left: 60, child: Icon(Icons.fingerprint, size: 40, color: Colors.white.withOpacity(0.08))),

        SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.balance, color: Colors.white, size: 26),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Notary Track",
                      style: GoogleFonts.comfortaa(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 100),
                Text(
                  title,
                  style: GoogleFonts.comfortaa(fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}