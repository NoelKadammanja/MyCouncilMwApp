import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/core/services/api_service.dart';
import 'package:local_govt_mw/core/services/offline_sync_service.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';

class AssignmentsController extends GetxController {
  ApiService get _apiService => Get.find<ApiService>();
  OfflineSyncService get _syncService => Get.find<OfflineSyncService>();

  final isLoading = false.obs;
  final isOffline = false.obs;
  final assignments = <InspectionAssignment>[].obs;
  final filteredAssignments = <InspectionAssignment>[].obs;
  final selectedFilter = 'All'.obs;

  final List<String> filters = [
    'All',
    'Pending',
    'Completed',
    'Rejected',
  ];

  @override
  void onInit() {
    super.onInit();
    ever(selectedFilter, (_) => applyFilter());
    ever(assignments, (_) => applyFilter());
    fetchAssignments();
  }

  Future<void> fetchAssignments() async {
    try {
      isLoading.value = true;

      // Try fetching from API first
      final response = await _apiService.get(ApiService.myAssignmentsEndpoint);
      final dynamic raw = response['content'];

      if (raw is List) {
        final fetched = raw.cast<Map<String, dynamic>>();
        assignments.value = fetched
            .map((json) => InspectionAssignment.fromJson(json))
            .toList();

        // Cache for offline use
        await _syncService.cacheAssignments(fetched);
        isOffline.value = false;

        debugPrint('AssignmentsController: fetched ${assignments.length} assignments from API');
        debugPrint('Pending: ${assignments.where((a) => a.isPendingInspection).length}');
        debugPrint('Completed: ${assignments.where((a) => a.isInspectionCompleted).length}');
      } else {
        assignments.clear();
        filteredAssignments.clear();
      }
    } catch (e) {
      debugPrint('AssignmentsController: API fetch failed, trying cache: $e');

      // Fall back to local cache
      final cached = await _syncService.getCachedAssignments();
      if (cached.isNotEmpty) {
        assignments.value = cached
            .map((json) => InspectionAssignment.fromJson(json))
            .toList();
        isOffline.value = true;

        debugPrint('AssignmentsController: loaded ${assignments.length} assignments from cache');

        Get.snackbar(
          'Offline Mode',
          'Showing cached assignments. Connect to internet to refresh.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.orange,
          colorText: Colors.white,
          margin: const EdgeInsets.all(12),
          duration: const Duration(seconds: 4),
        );
      } else {
        // No cache available
        final msg = e.toString();
        if (!msg.contains('Session expired')) {
          Get.snackbar(
            'Error',
            'Failed to load assignments and no cached data available.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
            margin: const EdgeInsets.all(12),
          );
        }
      }
    } finally {
      isLoading.value = false;
    }
  }

  void applyFilter() {
    if (selectedFilter.value == 'All') {
      filteredAssignments.value = List<InspectionAssignment>.from(assignments);
    } else {
      filteredAssignments.value = assignments
          .where((a) => a.formattedStatus == selectedFilter.value)
          .toList();
    }

    debugPrint('Filter: ${selectedFilter.value}, Showing: ${filteredAssignments.length} assignments');
  }

  void setFilter(String filter) {
    selectedFilter.value = filter;
  }

  void refreshAssignments() => fetchAssignments();

  /// Get statistics for homepage display
  Map<String, int> getStats() {
    return {
      'total': assignments.length,
      'pending': assignments.where((a) => a.isPendingInspection).length,
      'completed': assignments.where((a) => a.isInspectionCompleted).length,
    };
  }
}