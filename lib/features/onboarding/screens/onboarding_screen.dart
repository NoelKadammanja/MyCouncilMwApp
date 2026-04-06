import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
import 'package:local_govt_mw/features/auth/screens/registration/createaccount_selecttype_screen.dart';
import 'package:local_govt_mw/features/onboarding/domain/model/onboarding_model.dart';
import 'package:local_govt_mw/routes/app_routes.dart';
import 'package:local_govt_mw/features/profile/screens/help_center_screen.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController pageController = PageController();
  final List sliderPages = OnboardingModel.getSliderPageData();
  int currentPage = 0;

  Timer? autoSlideTimer;

  @override
  void initState() {
    super.initState();

    autoSlideTimer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (pageController.hasClients) {
        int nextPage =
            (pageController.page!.round() + 1) % sliderPages.length;

        pageController.animateToPage(
          nextPage,
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    autoSlideTimer?.cancel();
    pageController.dispose();
    super.dispose();
  }

  void setIndex(int index) {
    setState(() => currentPage = index);
  }

  @override
  Widget build(BuildContext context) {
    final imageHeight =
    min(520.0, MediaQuery.of(context).size.height * 0.60);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Column(
          children: [

            /// ================= Ts&Cs =================
            Padding(
              padding: const EdgeInsets.only(top: 8, right: 16),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: () => Get.to(() => const HelpCenterScreen()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border.all(
                        width: 2,
                        color: const Color(0xFF09AA57),
                      ),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.menu_rounded,
                          size: 20,
                          color: Colors.grey,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Ts&Cs",
                          style: TextStyle(
                            color: ColorConstant.blue700,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 10),

            /// ================= SLIDER (IMAGE ONLY) =================
            Expanded(
              child: PageView.builder(
                controller: pageController,
                onPageChanged: setIndex,
                itemCount: sliderPages.length,
                itemBuilder: (context, index) {
                  final item = sliderPages[index];

                  return Padding(
                    padding:
                    const EdgeInsets.symmetric(horizontal: 2),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: CustomImageView(
                        imagePath: item.image,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        height: imageHeight,
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 16),

            /// ================= DOT INDICATOR =================
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: List.generate(sliderPages.length, (index) {
            //     return AnimatedContainer(
            //       duration: const Duration(milliseconds: 300),
            //       height: 8,
            //       width: 8,
            //       margin: const EdgeInsets.symmetric(horizontal: 5),
            //       decoration: BoxDecoration(
            //         color: currentPage == index
            //             ? Colors.grey.shade700
            //             : Colors.grey.shade300,
            //         shape: BoxShape.circle,
            //       ),
            //     );
            //   }),
            // ),

            const SizedBox(height: 32),

            /// ================= LOGIN BUTTON (GRADIENT) =================
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 94),
              child: GestureDetector(
                onTap: () =>
                    Get.toNamed(AppRoutes.loginScreen),
                child: Container(
                  height: 45,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF0FCA6D), // Primary Government Green
                        Color(0xFF0D4D2C), // Deep Forest Green
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                  ),
                  child: const Center(
                    child: Text(
                      "Login",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// ================= REGISTER BUTTON (BORDERED) =================

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}