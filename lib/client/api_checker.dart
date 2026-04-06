import 'package:get/get.dart';

class ApiChecker {
  static void check(Response response) {
    if (response.statusCode == null) {
      throw Exception('No response from server');
    }

    if (response.statusCode! < 200 || response.statusCode! >= 300) {
      throw Exception(
        response.body?['message'] ?? 'API Error: ${response.statusCode}',
      );
    }
  }
}
