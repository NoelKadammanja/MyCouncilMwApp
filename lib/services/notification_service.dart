import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';
import 'package:local_govt_mw/controllers/notifications_controller.dart';

class NotificationService extends GetxService {
  NotificationsController get _controller => Get.find<NotificationsController>();

  @override
  void onInit() {
    super.onInit();
    debugPrint('NotificationService: Initialized');
    // Ensure controller is available
    if (!Get.isRegistered<NotificationsController>()) {
      debugPrint('NotificationService: Controller not found, creating...');
      Get.put(NotificationsController());
    }
  }

  // Delegate to controller
  RxList<Map<String, dynamic>> get notifications => _controller.notifications;
  int get pendingInspectionCount => _controller.pendingCount.value;

  Future<void> checkForNewAssignments(List<InspectionAssignment> assignments) async {
    debugPrint('NotificationService: Checking for new assignments...');
    await _controller.checkAndCreateNotifications(assignments);
  }

  Future<void> cleanupCompletedAssignments(List<InspectionAssignment> assignments) async {
    debugPrint('NotificationService: Cleaning up completed assignments...');
    await _controller.cleanupCompletedNotifications(assignments);
  }

  Future<void> markAsRead(String notificationId) async {
    await _controller.markAsRead(notificationId);
  }

  Future<void> markAllAsRead() async {
    await _controller.markAllAsRead();
  }

  Future<void> clearNotifications() async {
    await _controller.clearAll();
  }

  Future<void> refreshNotifications() async {
    await _controller.loadNotifications();
  }

  // Debug method
  Future<void> debugPrintState() async {
    await _controller.debugPrintState();
  }
}