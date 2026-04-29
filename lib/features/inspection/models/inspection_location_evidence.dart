import 'dart:io';

/// Holds either GPS coordinates or a timestamped photo as on-site evidence.
/// At least one of [latitude/longitude] OR [photoFile/photoFileId] must be present.
class InspectionLocationEvidence {
  final double? latitude;
  final double? longitude;
  final File? photoFile;
  final String? photoFileId; // UUID returned after uploading to server
  final DateTime capturedAt;

  InspectionLocationEvidence({
    this.latitude,
    this.longitude,
    this.photoFile,
    this.photoFileId,
    required this.capturedAt,
  });

  bool get hasGps => latitude != null && longitude != null;

  // hasPhoto is true if we have a server-side reference OR a local file
  bool get hasPhoto => photoFileId != null || photoFile != null;

  // photoUploaded is true only when we have the server-side UUID
  bool get photoUploaded => photoFileId != null;

  bool get isValid => hasGps || hasPhoto;

  /// Builds the locationEvidence JSON for the API payload.
  /// Only includes fields the server can actually use:
  ///   - GPS coords (if present)
  ///   - photoFileId UUID (only if photo has been successfully uploaded)
  ///
  /// NOTE: photoFile (local path) is intentionally NOT sent to server —
  /// it must be uploaded first via /upload-site-photo to get a photoFileId.
  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{
      'capturedAt': capturedAt.toIso8601String().substring(0, 19),
    };

    if (hasGps) {
      map['latitude'] = latitude;
      map['longitude'] = longitude;
    }

    // Only include photoFileId if the photo has been uploaded to the server
    if (photoFileId != null) {
      map['photoFileId'] = photoFileId;
    }

    // Local photo path is stored separately for offline sync
    // (not sent to the main submit endpoint)
    if (photoFile != null && photoFileId == null) {
      // Flag that there is a pending photo upload
      map['_pendingPhotoPath'] = photoFile!.path;
    }

    return map;
  }

  @override
  String toString() {
    return 'InspectionLocationEvidence('
        'hasGps=$hasGps, '
        'lat=$latitude, lng=$longitude, '
        'photoFileId=$photoFileId, '
        'hasLocalPhoto=${photoFile != null}, '
        'capturedAt=$capturedAt)';
  }
}