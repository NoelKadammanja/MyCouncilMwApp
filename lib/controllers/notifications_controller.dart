import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/data/local/notification_dao.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';

class NotificationsController extends GetxController {
  final NotificationDao _notificationDao = NotificationDao();

  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;
  final RxInt pendingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNotifications();
    debugPrint('NotificationsController: Initialized');
  }

  Future<void> loadNotifications() async {
    try {
      final savedNotifications = await _notificationDao.getNotifications();
      notifications.value = savedNotifications;
      updatePendingCount();
      debugPrint('NotificationsController: Loaded ${savedNotifications.length} notifications');
      for (var n in savedNotifications) {
        debugPrint('  - ${n['business_name']}: stage_code=${n['workflow_stage']}, read=${n['is_read']}');
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  void updatePendingCount() {
    // Count unread notifications where workflow_stage stores 'SUBMIT_INSPECTION'
    final count = notifications.where((n) {
      final isUnread = n['is_read'] == 0;
      final stageCode = n['workflow_stage']?.toString() ?? '';
      final isPending = stageCode == 'SUBMIT_INSPECTION';
      return isUnread && isPending;
    }).length;
    pendingCount.value = count;
    debugPrint('NotificationsController: Pending count updated to $count');
  }

  Future<void> checkAndCreateNotifications(List<InspectionAssignment> assignments) async {
    debugPrint('NotificationsController: Checking ${assignments.length} assignments for notifications');

    final existingNotifications = await _notificationDao.getNotifications();
    final existingAssignmentIds = existingNotifications
        .map((n) => n['assignment_id']?.toString())
        .where((id) => id != null)
        .toSet();

    int newCount = 0;

    for (var assignment in assignments) {
      // Use isPendingInspection which checks currentStageCode == 'SUBMIT_INSPECTION'
      final isPending = assignment.isPendingInspection;
      final hasNotification = existingAssignmentIds.contains(assignment.id);

      debugPrint('  Assignment: ${assignment.businessName}, isPending: $isPending, hasNotification: $hasNotification');

      if (isPending && !hasNotification) {
        final notificationId = '${assignment.id}_${DateTime.now().millisecondsSinceEpoch}';
        await _notificationDao.insertNotification({
          'id': notificationId,
          'assignment_id': assignment.id,
          'title': 'New Inspection Assignment',
          'body': 'You have been assigned to inspect ${assignment.businessName}',
          'business_name': assignment.businessName,
          'reference_number': assignment.referenceNumber,
          'status': assignment.status,
          // Store the stageCode (not stageName) so updatePendingCount can match reliably
          'workflow_stage': assignment.workflowStatus?.currentStageCode ?? 'SUBMIT_INSPECTION',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'is_read': 0,
        });
        newCount++;
        debugPrint('  ✓ Created notification for: ${assignment.businessName}');
      }
    }

    // Remove notifications for assignments that are no longer SUBMIT_INSPECTION
    // (i.e. they have moved past inspection stage since last sync)
    await _syncCompletedNotifications(assignments, existingNotifications);

    if (newCount > 0) {
      await loadNotifications();
      Get.snackbar(
        'New Inspections',
        'You have $newCount new inspection(s) pending',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1E7F4F),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        icon: const Icon(Icons.assignment_turned_in, color: Colors.white),
      );
    } else {
      await loadNotifications();
      debugPrint('NotificationsController: No new notifications to create');
    }
  }

  /// Removes stored notifications for assignments that have moved past SUBMIT_INSPECTION
  Future<void> _syncCompletedNotifications(
      List<InspectionAssignment> assignments,
      List<Map<String, dynamic>> existingNotifications,
      ) async {
    final completedIds = assignments
        .where((a) => !a.isPendingInspection)
        .map((a) => a.id)
        .toSet();

    int deletedCount = 0;
    for (var notification in existingNotifications) {
      final assignmentId = notification['assignment_id']?.toString();
      if (assignmentId != null && completedIds.contains(assignmentId)) {
        await _notificationDao.deleteNotification(notification['id'].toString());
        deletedCount++;
        debugPrint('  ✓ Removed notification for completed assignment: $assignmentId');
      }
    }

    if (deletedCount > 0) {
      debugPrint('NotificationsController: Removed $deletedCount completed notifications');
    }
  }

  Future<void> cleanupCompletedNotifications(List<InspectionAssignment> assignments) async {
    debugPrint('NotificationsController: Cleaning up completed assignments');
    final existingNotifications = await _notificationDao.getNotifications();
    await _syncCompletedNotifications(assignments, existingNotifications);
    await loadNotifications();
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationDao.markAsRead(notificationId);
    await loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _notificationDao.markAllAsRead();
    await loadNotifications();
  }

  Future<void> clearAll() async {
    await _notificationDao.clearAll();
    await loadNotifications();
  }

  Future<void> debugPrintState() async {
    debugPrint('=== NotificationsController Debug ===');
    debugPrint('Pending count: ${pendingCount.value}');
    debugPrint('Total notifications: ${notifications.length}');
    for (var n in notifications) {
      debugPrint('  - ${n['business_name']}: workflow_stage=${n['workflow_stage']}, is_read=${n['is_read']}');
    }
  }
}