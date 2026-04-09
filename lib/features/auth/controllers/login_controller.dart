import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:local_govt_mw/core/services/api_service.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';
import 'package:local_govt_mw/routes/app_routes.dart';

class LoginController extends GetxController {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool hidePassword = true.obs;
  final RxBool rememberMe = false.obs;
  final RxBool isLoading = false.obs;

  static const String _loginUrl = '${ApiService.baseUrl}/api/identity/login';

  // ─── Called once at startup by main.dart / splash to auto-login ──
  Future<bool> tryAutoLogin() async {
    final dao = UserDao();
    final isLoggedIn = await dao.isLoggedIn();
    if (isLoggedIn) {
      debugPrint('LoginController: auto-login successful from stored session');
      // Ensure ApiService is registered
      if (!Get.isRegistered<ApiService>()) {
        Get.put<ApiService>(ApiService(), permanent: true);
      }
      return true;
    }
    return false;
  }

  // ─── Standard credential login ────────────────────────────────────
  Future<void> login() async {
    if (isLoading.value) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter both email and password.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
      return;
    }

    isLoading.value = true;

    try {
      final url = Uri.parse(_loginUrl);
      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      )
          .timeout(const Duration(seconds: 30));

      debugPrint('LOGIN STATUS: ${response.statusCode}');
      debugPrint('LOGIN BODY:   ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final String token = (data['token'] ?? '').toString();

        if (token.isEmpty) {
          isLoading.value = false;
          Get.snackbar(
            'Login Failed',
            'Server did not return an authentication token.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
          );
          return;
        }

        // Step 1: Persist session using UserDao (SQLite)
        // The email from the form is included so UserDao can store it.
        final enrichedData = Map<String, dynamic>.from(data);
        if (!enrichedData.containsKey('email')) {
          enrichedData['email'] = email;
        }

        final userDao = UserDao();
        await userDao.saveUser(enrichedData);
        debugPrint('LOGIN: Session persisted to SQLite. Token = $token');

        // Step 2: Register ApiService
        if (!Get.isRegistered<ApiService>()) {
          Get.put<ApiService>(ApiService(), permanent: true);
          debugPrint('LOGIN: ApiService registered.');
        } else {
          debugPrint('LOGIN: ApiService already registered.');
        }

        isLoading.value = false;

        final String fullName =
        (data['fullName'] ?? data['full_name'] ?? '').toString();

        Get.snackbar(
          'Welcome back!',
          fullName.isNotEmpty
              ? 'Hello, $fullName 👋'
              : 'Logged in successfully',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF1E7F4F),
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );

        // Step 3: Navigate
        Get.offAllNamed(AppRoutes.appNavigationScreen);
      } else {
        isLoading.value = false;

        String errorMessage = 'Invalid email or password.';
        try {
          final errData = jsonDecode(response.body);
          if (errData is Map && errData['message'] != null) {
            errorMessage = errData['message'].toString();
          }
        } catch (_) {}

        Get.snackbar(
          'Login Failed',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } catch (e) {
      isLoading.value = false;
      debugPrint('LOGIN ERROR: $e');

      Get.snackbar(
        'Connection Error',
        'Could not reach the server. Check your network and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    }
  }

  // ─── Logout ───────────────────────────────────────────────────────
  Future<void> logout() async {
    final userDao = UserDao();
    await userDao.clearUser();

    // Unregister scoped services if needed
    if (Get.isRegistered<ApiService>()) {
      Get.delete<ApiService>();
    }

    debugPrint('LOGIN: User logged out, session cleared');
    Get.offAllNamed(AppRoutes.loginScreen);
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}