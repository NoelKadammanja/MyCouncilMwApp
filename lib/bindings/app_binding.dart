import 'package:get/get.dart';
import 'package:local_govt_mw/core/services/api_service.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    // permanent: true  → survives ALL route changes and screen disposals
    // fenix: true      → if somehow deleted, auto-recreates on next Get.find()
    Get.put<ApiService>(ApiService(), permanent: true);
  }
}