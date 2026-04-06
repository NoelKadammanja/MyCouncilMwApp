import 'package:get/get_connect/connect.dart';
import 'package:local_govt_mw/client/api_constants.dart';

class ApiClient extends GetConnect {
	ApiClient() {
		httpClient.baseUrl = ApiConstants.baseUrl;
	}
}
