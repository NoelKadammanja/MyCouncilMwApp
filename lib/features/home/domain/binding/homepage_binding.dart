
import 'package:get/get.dart';
import 'package:local_govt_mw/features/home/controllers/homepage_controller.dart';

class HomepageBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => HomepageController);
  }
}
