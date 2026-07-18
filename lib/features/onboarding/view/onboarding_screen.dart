import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

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

  final List<Map<String, String>> _onboardingData = [
    {
      "image": "assets/images/onboarding1.png",
      "title": "Pantau Setiap\nProses Dokumen",
      "desc":
          "Ikuti perkembangan dokumen secara real-time tanpa perlu datang langsung ke kantor notaris.",
    },
    {
      "image": "assets/images/onboarding2.png",
      "title": "Semua Dokumen,\nSatu Aplikasi",
      "desc":
          "Simpan, kelola, dan pantau seluruh dokumen penting dengan lebih praktis, aman, dan terorganisir.",
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
      MaterialPageRoute(
        builder: (context) => const LoginScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            /// Skip Button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: () => _presenter.skipOnboarding(),
                  child: Text(
                    "Lewati",
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ),
            ),

            /// PageView
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) =>
                    _presenter.handlePageChange(index),
                itemBuilder: (context, index) {
                  final item = _onboardingData[index];

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [

                        /// Illustration
                        SizedBox(
                          width: 320,
                          height: 320,
                          child: Image.asset(
                            item["image"]!,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 28),

                        /// Title
                        Text(
                          item["title"]!,
                          textAlign: TextAlign.center,
                          style: GoogleFonts.comfortaa(
                            fontSize: 28,
                            fontWeight: FontWeight.w700,
                            height: 1.3,
                            color:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        const SizedBox(height: 18),

                        /// Description
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          child: Text(
                            item["desc"]!,
                            textAlign: TextAlign.center,
                            style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              height: 1.7,
                              fontWeight: FontWeight.w500,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// Bottom Navigation
            Padding(
              padding: const EdgeInsets.fromLTRB(32, 16, 32, 32),
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.spaceBetween,
                children: [

                  /// Indicator
                  Row(
                    children: List.generate(
                      _onboardingData.length,
                      (index) {
                        final isActive =
                            _presenter.currentPage == index;

                        return AnimatedContainer(
                          duration:
                              const Duration(milliseconds: 250),
                          margin:
                              const EdgeInsets.only(right: 8),
                          width: isActive ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: isActive
                                ? Theme.of(context)
                                    .colorScheme
                                    .primary
                                : Theme.of(context)
                                    .dividerColor,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        );
                      },
                    ),
                  ),

                  /// Next Button
                  FloatingActionButton(
                    elevation: 3,
                    onPressed: () => _presenter
                        .handleNextAction(
                            _onboardingData.length),
                    shape: const CircleBorder(),
                    child: Icon(
                      _presenter.currentPage ==
                              _onboardingData.length - 1
                          ? Icons.check
                          : Icons.arrow_forward,
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