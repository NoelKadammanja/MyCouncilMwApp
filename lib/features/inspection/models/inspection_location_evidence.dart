import 'dart:io';

/// Holds either GPS coordinates or a timestamped photo as on-site evidence.
/// At least one of [latitude/longitude] OR [photoFile] must be present.
class InspectionLocationEvidence {
  final double? latitude;
  final double? longitude;
  final File? photoFile;
  final String? photoFileId; // returned after uploading to server
  final DateTime capturedAt;

  InspectionLocationEvidence({
    this.latitude,
    this.longitude,
    this.photoFile,
    this.photoFileId,
    required this.capturedAt,
  });

  bool get hasGps => latitude != null && longitude != null;
  bool get hasPhoto => photoFile != null || photoFileId != null;
  bool get isValid => hasGps || hasPhoto;

  /// Builds the locationEvidence portion of the JSON payload.
  /// If photo has been uploaded, use photoFileId.
  /// If photo is pending upload, this should be called AFTER uploading.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'capturedAt': capturedAt.toIso8601String().substring(0, 19),
    };
    if (hasGps) {
      map['latitude'] = latitude;
      map['longitude'] = longitude;
    }
    if (photoFileId != null) {
      map['photoFileId'] = photoFileId;
    }
    return map;
  }
}