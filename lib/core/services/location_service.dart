import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';  // ADD THIS

class LocationService extends GetxService {
  final RxBool isLocationEnabled = false.obs;
  final RxBool isPermissionGranted = false.obs;

  @override
  void onInit() {
    super.onInit();
    debugPrint('LocationService initialized');
  }

  /// Request location permissions with dialog
  Future<bool> requestLocationPermissions() async {
    // For Android 12+
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        debugPrint('Location permission denied');

        // Show dialog explaining why we need permission
        if (Get.context != null) {
          await _showPermissionDialog();
        }
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      debugPrint('Location permission permanently denied');

      // Show dialog to guide user to settings
      if (Get.context != null) {
        await _showSettingsDialog();
      }
      return false;
    }

    isPermissionGranted.value = true;
    return true;
  }

  Future<void> _showPermissionDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'This app needs location access to verify you are on-site for inspections. '
                'Please grant location permission to continue.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Get.back();
              requestLocationPermissions();
            },
            child: const Text('Allow'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSettingsDialog() async {
    final result = await Get.dialog(
      AlertDialog(
        title: const Text('Location Permission Required'),
        content: const Text(
            'Location permission is permanently denied. '
                'Please enable it in app settings to use GPS features.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await openAppSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Check and request location permissions
  Future<bool> checkAndRequestPermissions() async {
    return await requestLocationPermissions();
  }

  /// Get current GPS location
  Future<Position?> getCurrentLocation() async {
    try {
      final hasPermission = await checkAndRequestPermissions();
      if (!hasPermission) {
        debugPrint('Location permission denied');
        return null;
      }

      final isLocationServiceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!isLocationServiceEnabled) {
        debugPrint('Location services are disabled');
        isLocationEnabled.value = false;

        // Show dialog to enable location services
        if (Get.context != null) {
          await _showEnableLocationDialog();
        }
        return null;
      }

      isLocationEnabled.value = true;

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      return position;
    } catch (e) {
      debugPrint('Error getting location: $e');
      return null;
    }
  }

  Future<void> _showEnableLocationDialog() async {
    await Get.dialog(
      AlertDialog(
        title: const Text('Location Services Disabled'),
        content: const Text(
            'Please enable GPS/location services to capture your current location.'
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              await Geolocator.openLocationSettings();
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  /// Get location with timeout and retry
  Future<Position?> getLocationWithRetry({int maxRetries = 2}) async {
    for (int i = 0; i < maxRetries; i++) {
      final position = await getCurrentLocation();
      if (position != null) return position;
      await Future.delayed(Duration(seconds: i + 1));
    }
    return null;
  }
}