import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class PhotoCaptureService extends GetxService {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;

  /// Capture a timestamped photo for location evidence
  Future<File?> captureTimestampedPhoto({bool useCamera = true}) async {
    try {
      XFile? pickedFile;

      if (useCamera) {
        // Initialize camera if needed
        if (_cameras == null) {
          _cameras = await availableCameras();
        }

        if (_cameras != null && _cameras!.isNotEmpty) {
          pickedFile = await _picker.pickImage(source: ImageSource.camera);
        } else {
          pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        }
      } else {
        pickedFile = await _picker.pickImage(source: ImageSource.gallery);
      }

      if (pickedFile == null) return null;

      // Create a timestamped copy of the file
      final timestamp = DateTime.now();
      final fileName = 'inspection_${timestamp.year}${timestamp.month}${timestamp.day}_${timestamp.hour}${timestamp.minute}${timestamp.second}.jpg';

      final appDir = await getTemporaryDirectory();
      final savedFile = File('${appDir.path}/$fileName');

      // Copy the file to a new location with timestamp
      final originalFile = File(pickedFile.path);
      await originalFile.copy(savedFile.path);

      return savedFile;
    } catch (e) {
      debugPrint('Error capturing photo: $e');
      return null;
    }
  }

  Future<void> disposeCamera() async {
    await _cameraController?.dispose();
  }
}