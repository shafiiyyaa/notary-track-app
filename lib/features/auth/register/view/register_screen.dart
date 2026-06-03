import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../constants/constants.dart';
import '../presenter/register_presenter.dart';
import 'register_view.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> implements RegisterViewContract {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  late RegisterPresenter _presenter;

  @override
  void initState() {
    super.initState();
    _presenter = RegisterPresenter(this);
  }

  @override
  void showLoading() => setState(() => _isLoading = true);

  @override
  void hideLoading() => setState(() => _isLoading = false);

  @override
  void onRegisterSuccess() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Registrasi Berhasil! Silakan Cek Email/Login'), backgroundColor: Colors.green));
    Navigator.pop(context);
  }

  @override
  void onRegisterError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Daftar Akun', style: GoogleFonts.comfortaa(fontSize: 32, fontWeight: FontWeight.bold)),
              const SizedBox(height: 30),
              _buildLabel('Username'),
              TextField(controller: _usernameController, decoration: InputDecoration(filled: true, fillColor: AppColors.textFieldBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
              const SizedBox(height: 16),
              _buildLabel('Email'),
              TextField(controller: _emailController, decoration: InputDecoration(filled: true, fillColor: AppColors.textFieldBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
              const SizedBox(height: 16),
              _buildLabel('Password'),
              TextField(controller: _passwordController, obscureText: true, decoration: InputDecoration(filled: true, fillColor: AppColors.textFieldBg, border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none))),
              const SizedBox(height: 40),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : () => _presenter.performRegister(_emailController.text, _passwordController.text, _usernameController.text),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text('Buat Akun', style: TextStyle(color: Colors.white, fontSize: 18)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) => Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold))));
}