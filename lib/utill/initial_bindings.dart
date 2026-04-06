import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/data/datasource/api_client.dart';
import 'package:local_govt_mw/helper/network_info.dart';
import 'package:local_govt_mw/utill/pref_utils.dart';

class InitialBindings extends Bindings {
  @override
  void dependencies() {
    Get.put(PrefUtils());
    Get.put(ApiClient());
    Connectivity connectivity = Connectivity();
    Get.put(NetworkInfo(connectivity));
  }
}
