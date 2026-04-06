import 'dart:async';
import 'package:flutter/material.dart';
import 'package:local_govt_mw/features/onboarding/screens/onboarding_screen.dart';
import 'package:local_govt_mw/features/splash/domain/models/splash_model.dart';
import 'package:local_govt_mw/helper/network_info.dart';

class SplashController extends ChangeNotifier {
  final SplashModel splashModel;
  final NetworkInfo networkInfo;

  bool hasConnection = true;
  bool _firstTimeConnectionCheck = true;

  SplashController({
    required this.splashModel,
    required this.networkInfo,
  });

  bool get firstTimeConnectionCheck => _firstTimeConnectionCheck;

  void setFirstTimeConnectionCheck(bool value) {
    _firstTimeConnectionCheck = value;
    notifyListeners();
  }

  Future<void> checkNetworkStatus() async {
    hasConnection = await networkInfo.isConnected;
    notifyListeners();
  }

  void startConnectivityListener(BuildContext context) {
    NetworkInfo.checkConnectivity(context, this);
  }

  /// Initialize splash logic and handle transition
  Future<void> initApp(BuildContext context) async {
    await checkNetworkStatus();

    // Delay splash for branding effect (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    if (hasConnection) {
      // Navigate to onboarding screen with fade animation
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 800),
        pageBuilder: (_, __, ___) =>
            // Lazy import prevents circular reference
            // ignore: prefer_const_constructors
            OnboardingScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ));
    } else {
      // If offline, stay and retry later
      notifyListeners();
    }
  }
}
