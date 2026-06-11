import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:local_govt_mw/core/services/api_service.dart';
import 'package:local_govt_mw/core/services/branding_service.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';
import 'package:local_govt_mw/routes/app_routes.dart';

class LoginController extends GetxController {
  // ── Text-field controllers ─────────────────────────────────────────────
  /// Accepts email, phone number, or national ID.
  final TextEditingController identifierController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final RxBool hidePassword = true.obs;
  final RxBool isLoading = false.obs;

  static const String _loginUrl =
      '${ApiService.baseUrl}/api/identity/login';

  // ── Auto-login from stored session ────────────────────────────────────
  Future<bool> tryAutoLogin() async {
    final dao = UserDao();
    final loggedIn = await dao.isLoggedIn();
    if (loggedIn) {
      debugPrint('LoginController: auto-login from stored session');
      if (!Get.isRegistered<ApiService>()) {
        Get.put<ApiService>(ApiService(), permanent: true);
      }
      // Branding is already triggered in main.dart for the auto-login path,
      // but call it here too in case this method is invoked from elsewhere.
      if (Get.isRegistered<BrandingService>()) {
        Get.find<BrandingService>().loadBranding();
      }
      return true;
    }
    return false;
  }

  // ── Primary login ──────────────────────────────────────────────────────
  Future<void> login() async {
    if (isLoading.value) return;

    final identifier = identifierController.text.trim();
    final password = passwordController.text;

    if (identifier.isEmpty || password.isEmpty) {
      Get.snackbar(
        'Validation Error',
        'Please enter your username and password.',
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

      // The backend LoginRequest accepts `identifier` (new) or the legacy
      // `email` field. We always send `identifier` so phone numbers and
      // national IDs are handled correctly by the server.
      final body = jsonEncode({
        'identifier': identifier,
        'password': password,
      });

      debugPrint('LOGIN: POST $_loginUrl');
      debugPrint('LOGIN: identifier=${_mask(identifier)}');

      final response = await http
          .post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      )
          .timeout(const Duration(seconds: 30));

      debugPrint('LOGIN STATUS: ${response.statusCode}');
      debugPrint('LOGIN BODY:   ${response.body}');

      if (response.statusCode == 200) {
        await _handleSuccess(response.body, identifier);
      } else {
        _handleFailure(response.statusCode, response.body);
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');
      Get.snackbar(
        'Connection Error',
        'Could not reach the server. Check your network and try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
      );
    } finally {
      isLoading.value = false;
    }
  }

  // ── Success handler ────────────────────────────────────────────────────
  Future<void> _handleSuccess(String responseBody, String identifier) async {
    final data = jsonDecode(responseBody) as Map<String, dynamic>;
    final String token = (data['token'] ?? '').toString();

    if (token.isEmpty) {
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

    // Enrich the payload with the identifier the user typed so UserDao
    // always has something to store in the `email` column (which is used
    // as a display value in some screens). The server may or may not
    // return an email field depending on how the user registered.
    final enriched = Map<String, dynamic>.from(data);
    if (!enriched.containsKey('email') ||
        (enriched['email'] == null ||
            enriched['email'].toString().isEmpty)) {
      // Store whatever identifier was used (could be phone/national ID)
      // so downstream code that reads user['email'] still has a value.
      enriched['email'] = identifier;
    }

    // Persist session to SQLite — council_code is stored here, which
    // BrandingService will read via UserDao.getCouncilCode().
    final userDao = UserDao();
    await userDao.saveUser(enriched);
    debugPrint(
        'LOGIN: session persisted. Token=${token.substring(0, 10)}...');

    // Register ApiService if not already present
    if (!Get.isRegistered<ApiService>()) {
      Get.put<ApiService>(ApiService(), permanent: true);
    }

    // Trigger branding fetch now that the session (and council code) is saved
    if (Get.isRegistered<BrandingService>()) {
      Get.find<BrandingService>().loadBranding();
      debugPrint('LOGIN: BrandingService.loadBranding() triggered');
    }

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

    Get.offAllNamed(AppRoutes.appNavigationScreen);
  }

  // ── Failure handler ────────────────────────────────────────────────────
  void _handleFailure(int statusCode, String responseBody) {
    String message = 'Invalid credentials. Please try again.';

    try {
      final errData = jsonDecode(responseBody);
      if (errData is Map && errData['message'] != null) {
        message = errData['message'].toString();
      }
    } catch (_) {}

    // Friendlier messages for common HTTP codes
    if (statusCode == 401) {
      message =
      'Incorrect username or password. Please check your details and try again.';
    } else if (statusCode == 423) {
      message =
      'Your account has been temporarily locked due to too many failed attempts. '
          'Try again later or contact support.';
    } else if (statusCode == 403) {
      message =
      'Your account is disabled. Please contact your administrator.';
    }

    Get.snackbar(
      'Login Failed',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
      duration: const Duration(seconds: 5),
    );
  }

  // ── Logout ─────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final userDao = UserDao();
    await userDao.clearUser();

    // Clear cached branding so a different council's logo/colour does not
    // bleed into the next login session.
    if (Get.isRegistered<BrandingService>()) {
      Get.find<BrandingService>().clear();
      debugPrint('LOGIN: BrandingService cleared on logout');
    }

    if (Get.isRegistered<ApiService>()) {
      Get.delete<ApiService>();
    }

    debugPrint('LOGIN: logged out, session cleared');
    Get.offAllNamed(AppRoutes.loginScreen);
  }

  // ── Helpers ────────────────────────────────────────────────────────────

  /// Masks an identifier for safe debug logging (no PII in logs).
  String _mask(String raw) {
    if (raw.length < 4) return '***';
    if (raw.contains('@')) {
      final at = raw.indexOf('@');
      return '${raw[0]}***${raw.substring(at)}';
    }
    return '${raw.substring(0, 2)}***${raw.substring(raw.length - 2)}';
  }

  @override
  void onClose() {
    identifierController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}