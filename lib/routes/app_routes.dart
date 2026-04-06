import 'package:get/get.dart';
import 'package:local_govt_mw/features/auth/domain/binding/login_binding.dart';
import 'package:local_govt_mw/features/auth/domain/binding/otp_binding.dart';
import 'package:local_govt_mw/features/auth/screens/login_screen.dart';
import 'package:local_govt_mw/features/auth/screens/otp_screen.dart';
import 'package:local_govt_mw/features/balances/screens/moneymarkets_screen.dart';
import 'package:local_govt_mw/features/balances/screens/governmentsecurities_screen.dart';
import 'package:local_govt_mw/features/balances/screens/sharesbalance_screen.dart';
import 'package:local_govt_mw/features/home/domain/binding/homepage_binding.dart';
import 'package:local_govt_mw/features/home/screens/homepage_screen.dart';
import 'package:local_govt_mw/features/notification/domain/binding/notification_binding.dart';
import 'package:local_govt_mw/features/notification/screens/notification_screen.dart';
import 'package:local_govt_mw/features/onboarding/domain/binding/onboarding_binding.dart';
import 'package:local_govt_mw/features/onboarding/screens/onboarding_screen.dart';
import 'package:local_govt_mw/features/navigation/app_navigation_screen.dart';
import 'package:local_govt_mw/features/splash/screens/splash_screen.dart';
import 'package:local_govt_mw/features/inspection/screens/assignments_screen.dart';
import 'package:local_govt_mw/features/inspection/screens/checklist_screen.dart';
import 'package:local_govt_mw/features/inspection/screens/inspection_summary_screen.dart';
import 'package:local_govt_mw/features/inspection/domain/binding/inspection_binding.dart';

class AppRoutes {
  static const String splashScreen = '/splash_screen';
  static const String onboardingScreen = '/onboarding_screen';
  static const String loginScreen = '/login_screen';
  static const String otpScreen = '/otp_screen';
  static const String homepageScreen = '/homepage_screen';
  static const String notificationScreen = '/notification_screen';
  static const String profilePage = '/profile_page';
  static const String appNavigationScreen = '/app_navigation_screen';

  // Inspection routes
  static const String assignmentsScreen = '/assignments_screen';
  static const String checklistScreen = '/checklist_screen';
  static const String inspectionSummaryScreen = '/inspection_summary_screen';

  static List<GetPage> pages = [

    /// ✅ SPLASH FIRST
    GetPage(
      name: splashScreen,
      page: () => const SplashScreen(),
    ),

    GetPage(
      name: onboardingScreen,
      page: () => OnboardingScreen(),
      bindings: [
        OnboardingBinding(),
      ],
    ),

    GetPage(
      name: loginScreen,
      page: () => LoginScreen(),
      bindings: [
        LoginBinding(),
      ],
    ),

    GetPage(
      name: otpScreen,
      page: () => OtpScreen(),
      bindings: [
        OtpBinding(),
      ],
    ),

    GetPage(
      name: homepageScreen,
      page: () => HomepageScreen(),
      bindings: [
        HomepageBinding(),
      ],
    ),

    GetPage(
      name: appNavigationScreen,
      page: () => const AppNavigationScreen(),
    ),

    GetPage(
      name: notificationScreen,
      page: () => NotificationScreen(),
      bindings: [
        NotificationBinding(),
      ],
    ),

    GetPage(name: '/sharesBalance', page: () => SharesBalanceScreen()),
    GetPage(name: '/govtSecurities', page: () => GovtSecuritiesScreen()),
    GetPage(name: '/fixedDeposit', page: () => FixedDepositScreen()),

    // Inspection routes with binding
    GetPage(
      name: assignmentsScreen,
      page: () => const AssignmentsScreen(),
      binding: InspectionBinding(),
    ),
    GetPage(
      name: checklistScreen,
      page: () => ChecklistScreen(assignment: Get.arguments),
    ),
    GetPage(
      name: inspectionSummaryScreen,
      page: () => InspectionSummaryScreen(
        report: Get.arguments['report'],
        placeName: Get.arguments['placeName'],
      ),
    ),
  ];
}