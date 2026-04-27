import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_location_evidence.dart';

class LocationEvidenceService {
  final ImagePicker _picker = ImagePicker();

  /// Attempts to get GPS coordinates.
  /// Returns null if permission denied or location unavailable.
  Future<Position?> tryGetGps() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('LocationEvidenceService: location services disabled');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('LocationEvidenceService: location permission denied');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('LocationEvidenceService: location permission denied forever');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );

      debugPrint(
          'LocationEvidenceService: GPS captured lat=${position.latitude}, lng=${position.longitude}');
      return position;
    } catch (e) {
      debugPrint('LocationEvidenceService: GPS failed - $e');
      return null;
    }
  }

  /// Opens camera to capture a timestamped photo.
  /// Returns null if user cancels or camera unavailable.
  Future<File?> capturePhoto() async {
    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.rear,
      );

      if (photo == null) return null;

      return File(photo.path);
    } catch (e) {
      debugPrint('LocationEvidenceService: Camera failed - $e');
      return null;
    }
  }

  /// Formats GPS coordinates for display.
  String formatCoordinates(double lat, double lng) {
    final latDir = lat >= 0 ? 'N' : 'S';
    final lngDir = lng >= 0 ? 'E' : 'W';
    return '${lat.abs().toStringAsFixed(6)}°$latDir, ${lng.abs().toStringAsFixed(6)}°$lngDir';
  }

  /// Formats a timestamp for display on photos.
  String formatTimestamp(DateTime dt) {
    return DateFormat('dd MMM yyyy HH:mm:ss').format(dt);
  }
}