import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:local_govt_mw/services/notification_service.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final notificationService = Get.find<NotificationService>();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: CustomAppBar(
        title: 'Notifications',
        showBackButton: true,
      ),
      body: Obx(() {
        final notifications = notificationService.notifications;

        if (notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none,
                  size: 64,
                  color: const Color(0xFF64748B).withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No notifications yet',
                  style: TextStyle(
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          children: [
            if (notifications.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => notificationService.markAllAsRead(),
                      child: const Text(
                        'Mark all as read',
                        style: TextStyle(
                          color: Color(0xFF1E7F4F),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    TextButton(
                      onPressed: () => notificationService.clearNotifications(),
                      child: const Text(
                        'Clear all',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: notifications.length,
                itemBuilder: (context, index) {
                  final notification = notifications[index];
                  final isRead = notification['is_read'] == 1;
                  final createdAt = DateTime.fromMillisecondsSinceEpoch(
                    notification['created_at'] as int,
                  );

                  return GestureDetector(
                    onTap: () {
                      if (!isRead) {
                        notificationService.markAsRead(notification['id'].toString());
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isRead ? Colors.white : const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isRead
                              ? const Color(0xFFE5E7EB)
                              : const Color(0xFF1E7F4F).withOpacity(0.3),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'] ?? 'Notification',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 14,
                                    color: const Color(0xFF0F172A),
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1E7F4F),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Text(
                                    'NEW',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            notification['body'] ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFF64748B),
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 12,
                                color: const Color(0xFF64748B).withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat('MMM dd, yyyy - hh:mm a').format(createdAt),
                                style: TextStyle(
                                  fontSize: 11,
                                  color: const Color(0xFF64748B).withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      }),
    );
  }
}