import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'onboarding_screen.dart';

class CustomSplashScreen extends StatefulWidget {
  const CustomSplashScreen({super.key});

  @override
  State<CustomSplashScreen> createState() => _CustomSplashScreenState();
}

class _CustomSplashScreenState extends State<CustomSplashScreen> {
  @override
  void initState() {
    super.initState();
    // Jeda 3 detik lalu pindah ke halaman Onboarding
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingScreen()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     
      backgroundColor: const Color(0xFF5B8DB8),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 1. Bagian Logo Gambar
            Image.asset(
              'assets/images/logo.png',
              width: 180, // ukuran lebar logo di sini
              height: 180, // ukuran tinggi logo di sini
              fit: BoxFit.contain,
            ),

            const SizedBox(height: 16), // Jarak antara logo dan tulisan teks
            // 2. Bagian Tulisan "Notary Track" di bawah logo
            Text(
              'Notary Track',
              style: GoogleFonts.cinzel(
                fontSize: 32,
                fontWeight: FontWeight.w500,
                color: const Color(0xFFEFECE3),
                letterSpacing: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
