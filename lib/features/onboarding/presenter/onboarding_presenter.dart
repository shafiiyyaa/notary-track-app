import '../view/onboarding_view.dart';

class OnboardingPresenter {
  final OnboardingViewContract _view;
  int _currentPage = 0;

  OnboardingPresenter(this._view);

  int get currentPage => _currentPage;

  void handlePageChange(int index) {
    _currentPage = index;
    _view.onPageChanged(index);
  }

  void skipOnboarding() {
    _view.navigateToLogin();
      }

  void handleNextAction(int totalPages) {
    if (_currentPage < totalPages - 1) {
      _currentPage++;
      _view.onPageChanged(_currentPage);
    } else {
      _view.navigateToLogin();
    }
  }
}
