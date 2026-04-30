import 'package:get/get_connect/connect.dart';
import 'package:local_govt_mw/core/services/api_service.dart';

class ApiClient extends GetConnect {
	ApiClient() {
		httpClient.baseUrl = ApiService.baseUrl;
	}
}
