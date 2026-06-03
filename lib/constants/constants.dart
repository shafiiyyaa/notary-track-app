import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color background = Color(0xFFF5F3E9);
  static const Color primaryBlue = Color(0xFF5B8DB8);
  static const Color primaryBlueDark = Color(0xFF1E3A5F);
  static const Color cardBlueLight = Color(0xFFD2E3F0);
  static const Color cardBlueDark = Color(0xFFABC8E2);
  static const Color textFieldBg = Color(0xFFD2E1ED);

  static const Color statusBelumProses = Color(0xFFE86969);
  static const Color statusDiproses = Color(0xFFD6C052);
  static const Color statusSelesai = Color(0xFF6B8E7F);
}

class AppTextStyle {
  static TextStyle get titleStyle =>
      GoogleFonts.comfortaa(color: Colors.black, fontWeight: FontWeight.bold);

  static TextStyle get bodyStyle =>
      GoogleFonts.plusJakartaSans(color: Colors.black87);
}
