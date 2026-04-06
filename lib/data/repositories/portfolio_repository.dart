import 'package:local_govt_mw/client/api_checker.dart';
import 'package:local_govt_mw/client/api_constants.dart';
import 'package:local_govt_mw/data/datasource/api_client.dart';



class PortfolioRepository {
  final ApiClient apiClient;

  PortfolioRepository(this.apiClient);

  Future<dynamic> getPortfolio(String clientCode) async {
    final response = await apiClient.get(
      '${ApiConstants.clientPortfolio}/$clientCode',
    );

    ApiChecker.check(response);
    return response.body;
  }
}
