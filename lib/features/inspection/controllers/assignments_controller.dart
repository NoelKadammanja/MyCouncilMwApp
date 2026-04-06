import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/core/services/api_service.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';

class AssignmentsController extends GetxController {
  // ✅ Getter (not a field) so Get.find() is called at USE time, not at
  // construction time. By the time any method on this controller runs,
  // ApiService is guaranteed to be registered.
  ApiService get _apiService => Get.find<ApiService>();

  final isLoading = false.obs;
  final assignments = <InspectionAssignment>[].obs;
  final filteredAssignments = <InspectionAssignment>[].obs;
  final selectedFilter = 'All'.obs;

  final List<String> filters = [
    'All',
    'Pending',
    'In Progress',
    'Completed',
    'Rejected',
  ];

  @override
  void onInit() {
    super.onInit();
    // Automatically re-apply filter whenever selectedFilter or assignments change
    ever(selectedFilter, (_) => applyFilter());
    ever(assignments, (_) => applyFilter());
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    try {
      isLoading.value = true;

      final response =
      await _apiService.get(ApiService.myAssignmentsEndpoint);

      // ApiService._decode() wraps a top-level list as { "content": [...] }
      // and passes through a map that already has a "content" key.
      final dynamic raw = response['content'];

      if (raw is List) {
        assignments.value = raw
            .map((json) =>
            InspectionAssignment.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        // The map itself might be the assignment list under a different key,
        // or it may just be empty — clear gracefully.
        assignments.clear();
        filteredAssignments.clear();
      }
    } catch (e) {
      debugPrint('Error fetching assignments: $e');

      // Session-expired errors are already handled inside ApiService
      // (snackbar + redirect). Only show a UI error for other failures.
      final msg = e.toString();
      if (!msg.contains('Session expired')) {
        Get.snackbar(
          'Error',
          'Failed to load assignments. Please try again.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
        );
      }
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    if (selectedFilter.value == 'All') {
      filteredAssignments.value =
      List<InspectionAssignment>.from(assignments);
    } else {
      filteredAssignments.value = assignments
          .where((a) => a.formattedStatus == selectedFilter.value)
          .toList();
    }
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
    // applyFilter() is triggered automatically via ever()
  }

  void refreshAssignments() => fetchAssignments();
}