import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:local_govt_mw/features/splash/controllers/splash_controller.dart';

class NetworkInfo {
  final Connectivity connectivity;
  NetworkInfo(this.connectivity);

  /// Returns true if the device currently has an active network connection.
  Future<bool> get isConnected async {
    final result = await connectivity.checkConnectivity();
    return _hasConnection(result);
  }

  static bool _hasConnection(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.ethernet);
  }

  /// Subscribe to connectivity changes and show a snackbar + update the
  /// [SplashController] state.  Call this once from your root widget.
  static void checkConnectivity(
      BuildContext context,
      SplashController controller,
      ) {
    Connectivity().onConnectivityChanged.listen((List<ConnectivityResult> result) {
      if (controller.firstTimeConnectionCheck) {
        controller.setFirstTimeConnectionCheck(false);
      } else {
        final isConnected = _hasConnection(result);

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