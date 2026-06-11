import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_govt_mw/core/services/offline_sync_service.dart';
import 'package:local_govt_mw/core/services/location_service.dart';
import 'package:local_govt_mw/core/services/photo_capture_service.dart';
import 'package:local_govt_mw/core/services/branding_service.dart';
import 'package:local_govt_mw/data/local/database_helper.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';
import 'package:local_govt_mw/features/auth/controllers/login_controller.dart';
import 'package:local_govt_mw/services/notification_service.dart';
import 'package:local_govt_mw/controllers/notifications_controller.dart';
import 'features/splash/domain/models/splash_model.dart';
import 'features/splash/controllers/splash_controller.dart';
import 'helper/network_info.dart';
import 'routes/app_routes.dart';
import 'core/services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── 1. Initialize SQLite database FIRST ────────────────────────────────
  final dbHelper = DatabaseHelper();
  await dbHelper.database;
  debugPrint('MAIN: Database initialized');

  // ── 2. Register ApiService permanently ───────────────────────────
  final apiService = ApiService();
  await Get.putAsync<ApiService>(() async => apiService, permanent: true);
  debugPrint('MAIN: ApiService registered');

  // ── 3. Register LocationService ───────────────────────────────────
  await Get.putAsync<LocationService>(() async => LocationService(),
      permanent: true);
  debugPrint('MAIN: LocationService registered');

  // ── 4. Register PhotoCaptureService ──────────────────────────────
  await Get.putAsync<PhotoCaptureService>(() async => PhotoCaptureService(),
      permanent: true);
  debugPrint('MAIN: PhotoCaptureService registered');

  // ── 5. Register BrandingService permanently ───────────────────────
  Get.put<BrandingService>(BrandingService(), permanent: true);
  debugPrint('MAIN: BrandingService registered');

  // ── 6. Register NotificationsController (before NotificationService) ──
  final notificationsController = NotificationsController();
  Get.put<NotificationsController>(notificationsController, permanent: true);
  debugPrint('MAIN: NotificationsController registered');

  // ── 7. Register NotificationService permanently ───────────────────
  final notificationService = NotificationService();
  Get.put<NotificationService>(notificationService, permanent: true);
  debugPrint('MAIN: NotificationService registered');

  // ── 8. Register OfflineSyncService permanently ───────────────────
  Get.put<OfflineSyncService>(OfflineSyncService(), permanent: true);
  debugPrint('MAIN: OfflineSyncService registered');

  // ── 9. Determine initial route + trigger branding if already logged in ──
  final userDao = UserDao();
  final isLoggedIn = await userDao.isLoggedIn();

  if (isLoggedIn) {
    // User has a stored session — load branding immediately so the
    // app bar shows the correct logo/colour without waiting for a login.
    Get.find<BrandingService>().loadBranding();
    debugPrint('MAIN: BrandingService.loadBranding() triggered (auto-login)');
  }

  final initialRoute = isLoggedIn
      ? AppRoutes.appNavigationScreen
      : AppRoutes.splashScreen;

  debugPrint('MAIN: isLoggedIn=$isLoggedIn → initialRoute=$initialRoute');

  // ── 10. Splash / network setup ────────────────────────────────────
  final splashModel = SplashModel(
    appName: 'Local Govt Mw',
    slogan: 'Building Better Together',
    logoPath: 'assets/images/icon.png',
  );

  final networkInfo = NetworkInfo(Connectivity());

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SplashController(
            splashModel: splashModel,
            networkInfo: networkInfo,
          )..checkNetworkStatus(),
        ),
      ],
      child: MyApp(initialRoute: initialRoute),
    ),
  );
}

class MyApp extends StatelessWidget {
  final String initialRoute;

  const MyApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    final splashController =
    Provider.of<SplashController>(context, listen: false);
    splashController.startConnectivityListener(context);

    return GetMaterialApp(
      title: 'Inspection App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        textTheme: GoogleFonts.poppinsTextTheme(
          ThemeData.light().textTheme,
        ),
      ),
      initialRoute: initialRoute,
      getPages: AppRoutes.pages,
    );
  }
}