import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_response.dart';

class ApiClient {
  final String baseUrl;

  ApiClient({required this.baseUrl});

  Future<ApiResponse> get(String uri) async {
    try {
      final response = await http.get(Uri.parse(baseUrl + uri));
      return ApiResponse(
        statusCode: response.statusCode,
        body: jsonDecode(response.body),
      );
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }

  Future<ApiResponse> post(String uri, Map<String, dynamic> query) async {
    try {
      final url = Uri.parse(baseUrl + uri).replace(queryParameters: query);
      final response = await http.post(url);
      return ApiResponse(
        statusCode: response.statusCode,
        body: jsonDecode(response.body),
      );
    } catch (e) {
      return ApiResponse(error: e.toString());
    }
  }
}
