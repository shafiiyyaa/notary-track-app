import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/constants.dart';
import '../../auth/login/view/login_screen.dart';
import '../presenter/onboarding_presenter.dart';
import 'onboarding_view.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    implements OnboardingViewContract {
  final PageController _pageController = PageController();
  late OnboardingPresenter _presenter;

  // Data konten onboarding sesuai gambar 2 & 3 milikmu
  final List<Map<String, String>> _onboardingData = [
    {
      "title": "Mudah Memantau Progres Dokumen Notaris",
      "desc":
          "Pantau status pengerjaan dokumen akta, sertifikat, dan berkas penting lainnya secara real-time kapan saja.",
    },
    {
      "title": "Pengingat Tenggat Waktu Akurat",
      "desc":
          "Jangan lewatkan batas akhir pengurusan dokumen. Sistem pintar kami akan mengingatkan tenggat waktu penting Anda.",
    },
  ];

  @override
  void initState() {
    super.initState();
    _presenter = OnboardingPresenter(this);
  }

  @override
  void onPageChanged(int pageIndex) {
    setState(() {});
    _pageController.animateToPage(
      pageIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void navigateToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () => _presenter.skipOnboarding(),
                  child: Text(
                    'Lewati',
                    style: GoogleFonts.plusJakartaSans(
                      color: AppColors.primaryBlueDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Konten Slider Halaman
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => _presenter.handlePageChange(index),
                itemCount: _onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 240,
                          height: 240,
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            index == 0
                                ? Icons.assignment_outlined
                                : Icons.alarm_on_outlined,
                            size: 100,
                            color: AppColors.primaryBlueDark,
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          _onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryBlueDark,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _onboardingData[index]["desc"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: Colors.black54,
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.only(right: 8),
                        width: _presenter.currentPage == index ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _presenter.currentPage == index
                              ? AppColors.primaryBlue
                              : Colors.black26,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),

                  // Tombol Panah Keluar / Lanjut
                  FloatingActionButton(
                    onPressed: () =>
                        _presenter.handleNextAction(_onboardingData.length),
                    backgroundColor: AppColors.primaryBlue,
                    shape: const CircleBorder(),
                    child: Icon(
                      _presenter.currentPage == _onboardingData.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
