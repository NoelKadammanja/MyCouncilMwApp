import 'package:get/get.dart';
import 'package:local_govt_mw/features/auth/controllers/otp_controller.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => OtpController());
  }
}
