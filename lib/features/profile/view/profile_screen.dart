import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/constants.dart';
import '../model/profile_model.dart';
import '../presenter/profile.presenter.dart';
import 'profile_view.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> implements ProfileViewContract {
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
      backgroundColor: AppColors.background,
      body: _profile == null
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 40),
                      Text(
                        'Akun Saya',
                        style: GoogleFonts.comfortaa(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primaryBlueDark,
                        ),
                      ),
                      const SizedBox(height: 30),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                        child: CircleAvatar(
                          radius: 70,
                          backgroundImage: NetworkImage(_profile!.avatarUrl),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        _profile!.name,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _profile!.email,
                        style: GoogleFonts.plusJakartaSans(
                          fontSize: 14,
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 40),
                      _buildMenuItem(Icons.person, 'Edit Profil'),
                      _buildMenuItem(Icons.notifications, 'Notifikasi'),
                      _buildMenuItem(Icons.lock, 'Ubah Kata Sandi'),
                      _buildMenuItem(Icons.logout, 'Keluar'),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFD9E2ED), // Biru pastel estetik sesuai mockup
        borderRadius: BorderRadius.circular(20),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primaryBlueDark),
        title: Text(
          title,
          style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black),
        onTap: () {},
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }
}