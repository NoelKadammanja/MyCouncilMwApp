import 'package:get/get.dart';
import 'package:local_govt_mw/core/services/api_service.dart';

class InspectionBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<ApiService>()) {
      Get.put(ApiService(), permanent: true);
    }
  }
}