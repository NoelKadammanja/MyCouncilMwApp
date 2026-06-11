import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:local_govt_mw/core/services/api_service.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';

class BrandingService extends GetxService {
  final UserDao _userDao = UserDao();

  // ── Reactive state ───────────────────────────────────────────────
  final Rxn<Uint8List> logoBytes     = Rxn<Uint8List>();
  final RxString councilName         = ''.obs;
  final RxString councilCode         = ''.obs;
  final RxString primaryColor        = ''.obs;
  final RxString secondaryColor      = ''.obs;
  final RxBool   isLoading           = false.obs;
  final RxBool   hasLogo             = false.obs;

  // ── Load branding for the logged-in user's council ───────────────
  Future<void> loadBranding() async {
    isLoading.value = true;

    try {
      final code = await _userDao.getCouncilCode();
      if (code == null || code.isEmpty) {
        debugPrint('[BrandingService] No council code found');
        return;
      }
      councilCode.value = code;

      final user = await _userDao.getUser();
      councilName.value = user?['council_name']?.toString() ?? '';

      final token = await _userDao.getToken() ?? '';

      // ── Step 1: fetch branding metadata ─────────────────────────
      final brandingUri = Uri.parse(
        '${ApiService.baseUrl}/api/v1/councils/$code/branding',
      );

      debugPrint('[BrandingService] GET branding → $brandingUri');

      final brandingResp = await http.get(brandingUri, headers: {
        'Accept':        'application/json',
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 15));

      if (brandingResp.statusCode != 200) {
        debugPrint('[BrandingService] Branding fetch failed '
            '(${brandingResp.statusCode})');
        return;
      }

      final meta =
      jsonDecode(brandingResp.body) as Map<String, dynamic>;

      primaryColor.value   = meta['primaryColor']   ?? '';
      secondaryColor.value = meta['secondaryColor'] ?? '';

      final logoFileId = meta['logoFileId']?.toString() ?? '';
      if (logoFileId.isEmpty) {
        debugPrint('[BrandingService] No logoFileId in branding response');
        return;
      }

      // ── Step 2: fetch the logo image bytes ───────────────────────
      final logoUri = Uri.parse(
        '${ApiService.baseUrl}/api/v1/councils/$code/branding/logo',
      );

      debugPrint('[BrandingService] GET logo → $logoUri');

      final logoResp = await http.get(logoUri, headers: {
        'Accept':        '*/*',
        'Authorization': 'Bearer $token',
      }).timeout(const Duration(seconds: 20));

      if (logoResp.statusCode == 200 && logoResp.bodyBytes.isNotEmpty) {
        logoBytes.value = logoResp.bodyBytes;
        hasLogo.value   = true;
        debugPrint('[BrandingService] Logo loaded '
            '(${logoResp.bodyBytes.length} bytes)');
      } else {
        debugPrint('[BrandingService] Logo fetch failed '
            '(${logoResp.statusCode})');
      }
    } catch (e) {
      debugPrint('[BrandingService] Error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Call this on logout to wipe cached branding.
  void clear() {
    logoBytes.value      = null;
    hasLogo.value        = false;
    councilName.value    = '';
    councilCode.value    = '';
    primaryColor.value   = '';
    secondaryColor.value = '';
  }

  // ── Colour helpers ───────────────────────────────────────────────

  /// Parsed primary colour, or null if not yet loaded.
  Color? get primaryColorValue => _hexToColor(primaryColor.value);

  /// Parsed secondary colour, or null if not yet loaded.
  Color? get secondaryColorValue => _hexToColor(secondaryColor.value);

  static Color? _hexToColor(String hex) {
    if (hex.isEmpty) return null;
    final clean = hex.replaceAll('#', '');
    if (clean.length != 6) return null;
    return Color(int.parse('FF$clean', radix: 16));
  }
}