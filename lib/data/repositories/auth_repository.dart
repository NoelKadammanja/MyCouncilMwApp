import 'package:local_govt_mw/client/api_checker.dart';
import 'package:local_govt_mw/core/services/api_service.dart';
import 'package:local_govt_mw/data/datasource/api_client.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<Map<String, dynamic>> authenticate(
      String email, String password) async {
    final encodedEmail = Uri.encodeQueryComponent(email);
    final encodedPassword = Uri.encodeQueryComponent(password);
    final uri = '${ApiService.authenticate}?email=$encodedEmail&password=$encodedPassword';

    final response = await apiClient.post(uri, null);

    ApiChecker.check(response);
    return response.body;
  }
}
