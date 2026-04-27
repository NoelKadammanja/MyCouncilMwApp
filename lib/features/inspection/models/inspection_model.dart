import 'package:get/get.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_location_evidence.dart';

class InspectionAssignment {
  final String id; // This is the application ID
  final String businessId;
  final String businessName;
  final String categoryName;
  final String? councilId;
  final String? councilName;
  final DateTime? createdAt;
  final DateTime? expiryDate;
  final double? finalApprovedFee;
  final DateTime? issuedDate;
  final String ownerName;
  final String ownerType;
  final String referenceNumber;
  final String status;
  final String submittedByName;
  final String submittedByUserId;
  final String type; // NEW or RENEWAL
  final String? licenseTypeId;
  final WorkflowStatus? workflowStatus;

  InspectionAssignment({
    required this.id,
    required this.businessId,
    required this.businessName,
    required this.categoryName,
    this.councilId,
    this.councilName,
    this.createdAt,
    this.expiryDate,
    this.finalApprovedFee,
    this.issuedDate,
    required this.ownerName,
    required this.ownerType,
    required this.referenceNumber,
    required this.status,
    required this.submittedByName,
    required this.submittedByUserId,
    required this.type,
    this.licenseTypeId,
    this.workflowStatus,
  });

  factory InspectionAssignment.fromJson(Map<String, dynamic> json) {
    return InspectionAssignment(
      id: json['id'] ?? '',
      businessId: json['businessId'] ?? '',
      businessName: json['businessName'] ?? '',
      categoryName: json['categoryName'] ?? '',
      councilId: json['councilId']?.toString(),
      councilName: json['councilName'],
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : null,
      expiryDate: json['expiryDate'] != null ? DateTime.parse(json['expiryDate']) : null,
      finalApprovedFee: json['finalApprovedFee'] != null ? double.tryParse(json['finalApprovedFee'].toString()) : null,
      issuedDate: json['issuedDate'] != null ? DateTime.parse(json['issuedDate']) : null,
      ownerName: json['ownerName'] ?? '',
      ownerType: json['ownerType'] ?? '',
      referenceNumber: json['referenceNumber'] ?? '',
      status: json['status'] ?? 'PENDING_INSPECTION',
      submittedByName: json['submittedByName'] ?? '',
      submittedByUserId: json['submittedByUserId'] ?? '',
      type: json['type'] ?? 'NEW',
      licenseTypeId: json['licenseTypeId']?.toString(),
      workflowStatus: json['workflowStatus'] != null
          ? WorkflowStatus.fromJson(json['workflowStatus'])
          : null,
    );
  }

  /// Returns true if the inspection checklist has NOT been submitted yet
  bool get isPendingInspection {
    if (workflowStatus == null) return false;
    return workflowStatus!.currentStageCode == 'SUBMIT_INSPECTION';
  }

  /// Returns true if the inspection checklist HAS been submitted
  bool get isInspectionCompleted {
    if (workflowStatus == null) return false;
    return workflowStatus!.currentStageCode != 'SUBMIT_INSPECTION';
  }

  /// Returns user-friendly formatted status for display
  /// Returns user-friendly formatted status for display
  String get formattedStatus {
    if (workflowStatus == null) {
      switch (status) {
        case 'PENDING_INSPECTION':
          return 'Pending';
        case 'IN_PROGRESS':
          return 'In Progress';
        case 'APPROVED':
          return 'Completed';
        case 'REJECTED':
          return 'Rejected';
        default:
          return status.toLowerCase().replaceFirst(status[0], status[0].toUpperCase());
      }
    }

    final stageCode = workflowStatus!.currentStageCode;

    if (stageCode == 'SUBMIT_INSPECTION') {
      return 'Pending';
    } else if (stageCode.toLowerCase().contains('reject')) {
      return 'Rejected';
    } else {
      return 'Completed';
    }
  }

  String get placeAddress {
    return councilName ?? 'Address not specified';
  }

  String get placeType {
    return categoryName;
  }
}

/// Workflow status model to track the current stage of the application
class WorkflowStatus {
  final String currentStageCode;
  final String currentStageName;

  WorkflowStatus({
    required this.currentStageCode,
    required this.currentStageName,
  });

  factory WorkflowStatus.fromJson(Map<String, dynamic> json) {
    return WorkflowStatus(
      currentStageCode: json['currentStageCode'] ?? '',
      currentStageName: json['currentStageName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'currentStageCode': currentStageCode,
    'currentStageName': currentStageName,
  };
}

class ChecklistItem {
  final String id;
  final String title;
  final String description;
  String? selectedValue; // 'YES' or 'NO'
  String? comment;
  final String category;

  ChecklistItem({
    required this.id,
    required this.title,
    required this.description,
    this.selectedValue,
    this.comment,
    required this.category,
  });
}

class InspectionReport {
  final String id;
  final String assignmentId;
  final DateTime inspectionDate;
  final List<ChecklistItem> checklist;
  final String inspectorNotes;
  final double overallRating;
  final String status;

  InspectionReport({
    required this.id,
    required this.assignmentId,
    required this.inspectionDate,
    required this.checklist,
    required this.inspectorNotes,
    required this.overallRating,
    required this.status,
  });
}

class InspectionResultSubmit {
  final String applicationId;
  final List<InspectionResultItem> results;
  final InspectionLocationEvidence locationEvidence;

  InspectionResultSubmit({
    required this.applicationId,
    required this.results,
    required this.locationEvidence,
  });

  Map<String, dynamic> toJson() => {
    'applicationId': applicationId,
    'results': results.map((e) => e.toJson()).toList(),
    'locationEvidence': locationEvidence.toJson(),
  };
}

class InspectionResultItem {
  final String checklistItemId;
  final String value; // 'YES' or 'NO'
  final String? comment;

  InspectionResultItem({
    required this.checklistItemId,
    required this.value,
    this.comment,
  });

  Map<String, dynamic> toJson() => {
    'checklistItemId': checklistItemId,
    'value': value,
    if (comment != null && comment!.isNotEmpty) 'comment': comment,
  };
}