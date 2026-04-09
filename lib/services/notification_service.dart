import 'package:flutter/material.dart'; // Add this import
import 'package:get/get.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';
import 'package:local_govt_mw/data/local/notification_dao.dart';

class NotificationService extends GetxService {
  final NotificationDao _notificationDao = NotificationDao();
  final RxInt unreadCount = 0.obs;
  final RxList<Map<String, dynamic>> notifications = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final savedNotifications = await _notificationDao.getNotifications();
    notifications.value = savedNotifications;
    unreadCount.value = notifications.where((n) => n['is_read'] == 0).length;
  }

  Future<void> checkForNewAssignments(List<InspectionAssignment> currentAssignments) async {
    final savedNotifications = await _notificationDao.getNotifications();
    final existingAssignmentIds = savedNotifications
        .map((n) => n['assignment_id']?.toString())
        .where((id) => id != null)
        .toSet();

    final newAssignments = currentAssignments.where(
            (a) => !existingAssignmentIds.contains(a.id)
    ).toList();

    for (var assignment in newAssignments) {
      await _notificationDao.insertNotification({
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'assignment_id': assignment.id,
        'title': 'New Inspection Assignment',
        'body': 'You have been assigned to inspect ${assignment.businessName}',
        'business_name': assignment.businessName,
        'reference_number': assignment.referenceNumber,
        'status': assignment.status,
        'created_at': DateTime.now().millisecondsSinceEpoch,
        'is_read': 0,
      });
    }

    if (newAssignments.isNotEmpty) {
      await _loadNotifications();

      // Show snackbar for new assignments
      Get.snackbar(
        'New Assignments',
        'You have ${newAssignments.length} new inspection assignment(s)',
        snackPosition: SnackPosition.TOP,
        backgroundColor: const Color(0xFF1E7F4F),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> markAsRead(String notificationId) async {
    await _notificationDao.markAsRead(notificationId);
    await _loadNotifications();
  }

  Future<void> markAllAsRead() async {
    await _notificationDao.markAllAsRead();
    await _loadNotifications();
  }

  Future<void> clearNotifications() async {
    await _notificationDao.clearAll();
    notifications.clear();
    unreadCount.value = 0;
  }
}