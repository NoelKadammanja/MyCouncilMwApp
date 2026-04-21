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
        debugPrint('  - ${n['business_name']}: stage=${n['workflow_stage']}, read=${n['is_read']}');
      }
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  void updatePendingCount() {
    final count = notifications.where((n) {
      final isRead = n['is_read'] == 0;
      final workflowStage = n['workflow_stage']?.toString() ?? '';
      final isPending = workflowStage.contains('Pending Site Inspection ');
      return isRead && isPending;
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
      // Check if assignment is pending inspection
      final isPending = assignment.isPendingInspection;
      // Check if we already have a notification for this assignment
      final hasNotification = existingAssignmentIds.contains(assignment.id);

      debugPrint('  Assignment: ${assignment.businessName}, isPending: $isPending, hasNotification: $hasNotification');

      if (isPending && !hasNotification) {
        final notificationId = DateTime.now().millisecondsSinceEpoch.toString();
        await _notificationDao.insertNotification({
          'id': notificationId,
          'assignment_id': assignment.id,
          'title': 'New Inspection Assignment',
          'body': 'You have been assigned to inspect ${assignment.businessName}',
          'business_name': assignment.businessName,
          'reference_number': assignment.referenceNumber,
          'status': assignment.status,
          'workflow_stage': assignment.workflowStatus?.currentStageName ?? 'Pending Site Inspection ',
          'created_at': DateTime.now().millisecondsSinceEpoch,
          'is_read': 0,
        });
        newCount++;
        debugPrint('  ✓ Created notification for: ${assignment.businessName}');
      }
    }

    if (newCount > 0) {
      await loadNotifications();

      // Show snackbar
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
      debugPrint('NotificationsController: No new notifications to create');
    }
  }

  Future<void> cleanupCompletedNotifications(List<InspectionAssignment> assignments) async {
    final completedIds = assignments
        .where((a) => !a.isPendingInspection)
        .map((a) => a.id)
        .toSet();

    debugPrint('NotificationsController: Cleaning up ${completedIds.length} completed assignments');

    final allNotifications = await _notificationDao.getNotifications();
    int deletedCount = 0;

    for (var notification in allNotifications) {
      final assignmentId = notification['assignment_id']?.toString();
      if (assignmentId != null && completedIds.contains(assignmentId)) {
        await _notificationDao.deleteNotification(notification['id'].toString());
        deletedCount++;
        debugPrint('  ✓ Deleted notification for completed assignment: $assignmentId');
      }
    }

    if (deletedCount > 0) {
      debugPrint('NotificationsController: Cleaned up $deletedCount notifications');
      await loadNotifications();
    }
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

  // For debugging
  Future<void> debugPrintState() async {
    debugPrint('=== NotificationsController Debug ===');
    debugPrint('Pending count: ${pendingCount.value}');
    debugPrint('Total notifications: ${notifications.length}');
    for (var n in notifications) {
      debugPrint('  - ${n['business_name']}: workflow_stage=${n['workflow_stage']}, is_read=${n['is_read']}');
    }
  }
}