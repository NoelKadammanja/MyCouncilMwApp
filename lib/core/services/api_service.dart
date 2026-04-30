import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';
import 'package:local_govt_mw/routes/app_routes.dart';
import 'package:http_parser/http_parser.dart';

class ApiService extends GetxService {
  static const String baseUrl = 'https://nico-customerportal.com';
  static const String authenticate = '/api/v1/authenticate';

  // ─── Endpoints ────────────────────────────────────────────────────────────
  //get signed in inspector assignments
  static const String myAssignmentsEndpoint =
      '/api/licensing/applications/my-assignments';
  // submit inspection results from checklist
  static const String submitInspectionEndpoint = '/api/v1/inspection/results/submit-result';

  final UserDao _userDao = UserDao();

  // ─── Headers ──────────────────────────────────────────────────────────────

  Future<Map<String, String>> _getHeaders() async {
    final token = await _userDao.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  // ─── Session expiry ───────────────────────────────────────────────────────

  Future<void> _handleSessionExpired() async {
    await _userDao.clear();

    if (Get.currentRoute != AppRoutes.loginScreen) {
      Get.snackbar(
        'Session Expired',
        'Please log in again to continue.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
      // Small delay so the snackbar is visible before the screen swaps
      await Future.delayed(const Duration(milliseconds: 400));
      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }

  // ─── Response handler ─────────────────────────────────────────────────────

  /// Decodes the response body and returns a [Map<String, dynamic>].
  /// Top-level JSON arrays are wrapped as `{ "content": [...] }` so every
  /// caller can always expect a Map.
  Map<String, dynamic> _decode(http.Response response) {
    final body = response.body.isEmpty ? '{}' : response.body;

    dynamic decoded;
    try {
      decoded = jsonDecode(body);
    } catch (_) {
      throw Exception('Invalid JSON from server');
    }

    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is List) {
      // Wrap list so callers always get a Map
      return {'content': decoded};
    }

    throw Exception('Unexpected response format from server');
  }

  // ─── HTTP verbs ───────────────────────────────────────────────────────────

  Future<Map<String, dynamic>> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    debugPrint('[ApiService] GET $uri');

    final response = await http
        .get(uri, headers: headers)
        .timeout(const Duration(seconds: 30));

    debugPrint('[ApiService] ${response.statusCode} <- GET $endpoint');
    debugPrint('[ApiService] body: ${response.body}');

    if (response.statusCode == 401) {
      await _handleSessionExpired();
      throw Exception('Session expired. Please login again.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _decode(response);
    }

    throw Exception(
        'Request failed [${response.statusCode}]: ${response.body}');
  }

  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    debugPrint('[ApiService] POST $uri');

    final response = await http
        .post(uri, headers: headers, body: jsonEncode(data))
        .timeout(const Duration(seconds: 30));

    debugPrint('[ApiService] ${response.statusCode} <- POST $endpoint');
    debugPrint('[ApiService] body: ${response.body}');

    if (response.statusCode == 401) {
      await _handleSessionExpired();
      throw Exception('Session expired. Please login again.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _decode(response);
    }

    throw Exception(
        'Request failed [${response.statusCode}]: ${response.body}');
  }

  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _getHeaders();

    debugPrint('[ApiService] PUT $uri');

    final response = await http
        .put(uri, headers: headers, body: jsonEncode(data))
        .timeout(const Duration(seconds: 30));

    debugPrint('[ApiService] ${response.statusCode} <- PUT $endpoint');
    debugPrint('[ApiService] body: ${response.body}');

    if (response.statusCode == 401) {
      await _handleSessionExpired();
      throw Exception('Session expired. Please login again.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      return _decode(response);
    }

    throw Exception(
        'Request failed [${response.statusCode}]: ${response.body}');
  }

  /// Uploads a site photo and returns the photoFileId UUID from the server.
  Future<String> uploadSitePhoto(File photoFile) async {
    final uri = Uri.parse(
        '$baseUrl/api/v1/inspection/results/upload-site-photo');
    final token = await _userDao.getToken();

    debugPrint('[uploadSitePhoto] Starting upload...');
    debugPrint('[uploadSitePhoto] File path: ${photoFile.path}');

    if (!await photoFile.exists()) {
      throw Exception(
          'Photo file does not exist at path: ${photoFile.path}');
    }

    final fileLength = await photoFile.length();
    debugPrint('[uploadSitePhoto] File size: $fileLength bytes');
    if (fileLength == 0) {
      throw Exception('Photo file is empty (0 bytes)');
    }

    // Always force image/jpeg — Android camera temp files often
    // lose their extension and get sniffed as application/octet-stream.
    // Reading bytes directly with fromBytes() + explicit contentType
    // bypasses all MIME sniffing issues entirely.
    final contentType = MediaType('image', 'jpeg');
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final filename = 'inspection_photo_$timestamp.jpg';

    debugPrint('[uploadSitePhoto] contentType: $contentType | filename: $filename');

    final request = http.MultipartRequest('POST', uri);

    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }
    request.headers['Accept'] = 'application/json';

    // Use fromBytes — avoids MIME type sniffing from file path
    request.files.add(
      http.MultipartFile.fromBytes(
        'photo',
        await photoFile.readAsBytes(),
        filename: filename,
        contentType: contentType,
      ),
    );

    debugPrint('[uploadSitePhoto] Sending request to $uri...');

    final streamedResponse = await request.send().timeout(
      const Duration(seconds: 60),
      onTimeout: () =>
      throw Exception('Photo upload timed out after 60 seconds'),
    );

    final response = await http.Response.fromStream(streamedResponse);

    debugPrint('[uploadSitePhoto] Status: ${response.statusCode}');
    debugPrint('[uploadSitePhoto] Body:   ${response.body}');

    if (response.statusCode == 401) {
      await _handleSessionExpired();
      throw Exception('Session expired. Please login again.');
    }

    if (response.statusCode == 200 || response.statusCode == 201) {
      final decoded = _decode(response);
      final photoFileId = decoded['photoFileId']?.toString();
      if (photoFileId == null || photoFileId.isEmpty) {
        throw Exception(
            'Server did not return a photoFileId. Body: ${response.body}');
      }
      debugPrint('[uploadSitePhoto] SUCCESS: photoFileId=$photoFileId');
      return photoFileId;
    }

    throw Exception(
        'Photo upload failed [${response.statusCode}]: ${response.body}');
  }

  /// Builds a safe filename with the correct extension for the server.
  String _buildFileName(String filePath, MediaType contentType) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final ext = contentType.subtype; // 'jpeg', 'png', 'webp'
    return 'inspection_photo_$timestamp.$ext';
  }
}