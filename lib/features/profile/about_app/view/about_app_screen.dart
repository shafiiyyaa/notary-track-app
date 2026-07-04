import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../model/about_app_model.dart';
import '../presenter/about_app_presenter.dart';
import 'about_app_view.dart';

class AboutAppScreen extends StatefulWidget {
  const AboutAppScreen({super.key});

  @override
  State<AboutAppScreen> createState() => _AboutAppScreenState();
}

class _AboutAppScreenState extends State<AboutAppScreen>
    implements AboutAppViewContract {
  late AboutAppPresenter presenter;
  AboutAppModel? about;

  @override
  void initState() {
    super.initState();

    presenter = AboutAppPresenter(this);
    presenter.loadData();
  }

  @override
  void showData(AboutAppModel data) {
    setState(() {
      about = data;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (about == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  Text(
                    "Tentang Aplikasi",
                    style: GoogleFonts.comfortaa(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.titleLarge?.color,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              Icon(
                Icons.description_outlined,
                size: 80,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 20),

              Text(
                about!.appName,
                style: GoogleFonts.comfortaa(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.titleLarge?.color,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                about!.version,
                style: Theme.of(context).textTheme.bodyMedium,
              ),

              const SizedBox(height: 25),

              Expanded(
                child: SingleChildScrollView(
                  child: Text(
                    about!.description,
                    textAlign: TextAlign.justify,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 15,
                      height: 1.8,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
              ),

              Divider(color: Theme.of(context).dividerColor),

              const SizedBox(height: 10),

              Text(
                "Dikembangkan sebagai aplikasi skripsi Program Studi Informatika\nuntuk mendukung digitalisasi administrasi pada\nKantor Notaris dan PPAT Saptadi Setya Nugraha.",
                textAlign: TextAlign.center,
                style: GoogleFonts.plusJakartaSans(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "© 2026 Notary Track",
                style: GoogleFonts.comfortaa(
                  fontSize: 12,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}