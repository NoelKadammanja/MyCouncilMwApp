import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:local_govt_mw/features/onboarding/controllers/onboarding_controller.dart';
import 'features/splash/domain/models/splash_model.dart';
import 'features/splash/controllers/splash_controller.dart';
import 'helper/network_info.dart';
import 'routes/app_routes.dart';
import 'core/services/api_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize splash model & network info
  final splashModel = SplashModel(
    appName: 'NAML',
    slogan: 'Building Better Together',
    logoPath: 'assets/images/icon.png', // Make sure this exists in assets
  );

  final networkInfo = NetworkInfo(Connectivity());

  // Initialize ApiService and register with GetX
  final apiService = ApiService();
  await Get.putAsync<ApiService>(() async => apiService);

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SplashController(
            splashModel: splashModel,
            networkInfo: networkInfo,
          )..checkNetworkStatus(),
        ),
        ChangeNotifierProvider(
          create: (_) => OnboardingController(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Start connectivity listener
    final splashController = Provider.of<SplashController>(context, listen: false);
    splashController.startConnectivityListener(context);

    return GetMaterialApp(   // Use GetMaterialApp instead of MaterialApp
      title: 'My Council App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      initialRoute: AppRoutes.splashScreen,
      getPages: AppRoutes.pages, // GetX route definitions
    );
  }
}