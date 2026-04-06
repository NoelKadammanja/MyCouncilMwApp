import 'package:flutter/material.dart';
import 'package:local_govt_mw/features/onboarding/domain/model/onboarding_model.dart';
import 'package:local_govt_mw/features/onboarding/domain/model/slider_item_model.dart';

class OnboardingController extends ChangeNotifier {
  final PageController pageController = PageController();
  final List<SliderItemModel> slides = OnboardingModel.getSliderPageData();

  int currentPage = 0;

  void setCurrentPage(int index) {
    currentPage = index;
    notifyListeners();
  }

  void nextPage() {
    if (currentPage < slides.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    }
  }

  void goToPage(int index) {
    pageController.jumpToPage(index);
  }
}
