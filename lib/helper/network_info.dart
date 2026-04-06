import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:local_govt_mw/features/splash/controllers/splash_controller.dart';


class NetworkInfo {
  final Connectivity connectivity;
  NetworkInfo(this.connectivity);

  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return result.contains(ConnectivityResult.mobile) ||
           result.contains(ConnectivityResult.wifi);
  }

  static void checkConnectivity(BuildContext context, SplashController controller) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (controller.firstTimeConnectionCheck) {
        controller.setFirstTimeConnectionCheck(false);
      } else {
        bool isConnected = result.contains(ConnectivityResult.wifi) ||
                           result.contains(ConnectivityResult.mobile);

        ScaffoldMessenger.of(context).hideCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: isConnected ? Colors.green : Colors.red,
          duration: Duration(seconds: isConnected ? 3 : 6),
          content: Text(
            isConnected ? 'Connected' : 'No Internet Connection',
            textAlign: TextAlign.center,
          ),
        ));

        controller.hasConnection = isConnected;
        controller.notifyListeners();
      }
    });
  }
}
