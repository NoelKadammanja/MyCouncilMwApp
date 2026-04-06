import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:local_govt_mw/features/home/domain/model/homepage_model.dart';

class HomepageController extends GetxController {
  HomepageController(this.homepageModelObj);

  Rx<HomepageModel> homepageModelObj;
int id = 1;
  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void setButtonId(int i) {
    id = i;
    update();
  }
}
