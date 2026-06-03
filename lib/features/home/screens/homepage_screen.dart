import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';
import 'package:local_govt_mw/features/inspection/screens/checklist_screen.dart';
import 'package:local_govt_mw/routes/app_routes.dart';
import 'package:local_govt_mw/features/inspection/screens/assignments_screen.dart';
import 'package:local_govt_mw/features/inspection/controllers/assignments_controller.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';
import 'package:local_govt_mw/services/notification_service.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  static const Color kBg = Color(0xFFF3F4F6);
  static const Color kCard = Colors.white;
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);
  static const Color kPrimaryGreen = Color(0xFF1E7F4F);

  // User data
  String fullName = '';
  String email = '';
  String role = '';
  String councilName = '';

  // Inspector specific data
  int totalAssignments = 0;
  int pendingAssignments = 0;
  int completedAssignments = 0;
  List<InspectionAssignment> recentAssignments = [];

  final AssignmentsController _assignmentsController = Get.put(AssignmentsController());

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      final dao = UserDao();
      final user = await dao.getUser();
      if (user != null) {
        debugPrint('=== User Data from DAO ===');
        debugPrint('All keys: ${user.keys}');
        debugPrint('council_name: ${user['council_name']}');
        debugPrint('council: ${user['council']}');
        debugPrint('Full user: $user');

        setState(() {
          fullName = user['name']?.toString() ?? user['fullName']?.toString() ?? 'User';
          email = user['email']?.toString() ?? '';
          role = user['role']?.toString() ?? '';
          councilName = user['council_name']?.toString() ??
              (user['council'] as Map?)?.toString() ??
              'Council';
        });

        if (_isInspectorRole()) {
          _loadInspectorData();
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  Future<void> _refreshNotifications() async {
    try {
      if (Get.isRegistered<NotificationService>()) {
        final notificationService = Get.find<NotificationService>();
        await notificationService.refreshNotifications();
        debugPrint('HomepageScreen: Notifications refreshed');
      }
    } catch (e) {
      debugPrint('Error refreshing notifications: $e');
    }
  }

  bool _isInspectorRole() {
    return role == 'LICENSING_INSPECTOR' || role == 'INSPECTOR';
  }

  Future<void> _loadInspectorData() async {
    await Future.delayed(const Duration(milliseconds: 500));

    final currentAssignments = _assignmentsController.assignments.toList();

    int pending = 0;
    int completed = 0;

    for (var assignment in currentAssignments) {
      if (assignment.isPendingInspection) {
        pending++;
      } else if (assignment.isInspectionCompleted) {
        completed++;
      }
    }

    setState(() {
      totalAssignments = currentAssignments.length;
      pendingAssignments = pending;
      completedAssignments = completed;
      recentAssignments = currentAssignments.take(5).toList();
    });

    try {
      if (Get.isRegistered<NotificationService>()) {
        final notificationService = Get.find<NotificationService>();
        await notificationService.checkForNewAssignments(currentAssignments);
        await notificationService.cleanupCompletedAssignments(currentAssignments);
        await notificationService.refreshNotifications();
      }
    } catch (e) {
      debugPrint('Error checking notifications: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: CustomAppBar(
        title: 'Inspector Home',
        showBackButton: false,
      ),
      body: SafeArea(
        top: false,
        child: _isInspectorRole()
            ? _buildInspectorView()
            : _buildUnauthorizedView(),
      ),
    );
  }

  // ===========================================================================
  // INSPECTOR VIEW
  // ===========================================================================

  Widget _buildInspectorView() {
    return Obx(() {
      final isLoading = _assignmentsController.isLoading.value;
      final assignments = _assignmentsController.assignments;

      if (!isLoading && assignments.isNotEmpty && totalAssignments != assignments.length) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _loadInspectorData();
        });
      }

      return CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
              child: Column(
                children: [
                  _InspectorProfileCard(
                    fullName: fullName,
                    role: 'Licensing Inspector',
                    email: email,
                    councilName: councilName,
                  ),
                  const SizedBox(height: 16),
                  _StatsGrid(
                    total: totalAssignments,
                    pending: pendingAssignments,
                    completed: completedAssignments,
                  ),
                  const SizedBox(height: 16),
                  _RecentInspectionsCard(
                    recentAssignments: recentAssignments,
                    isLoading: isLoading,
                    onViewAll: () => Get.to(() => const AssignmentsScreen(showBackButton: true)),
                  ),
                ],
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],
      );
    });
  }

  // ===========================================================================
  // UNAUTHORIZED VIEW
  // ===========================================================================

  Widget _buildUnauthorizedView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_outline_rounded,
                size: 44,
                color: Colors.redAccent,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Unauthorized Access',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: kText,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'You do not have permission to access this application. This portal is restricted to Licensing Inspectors only.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                height: 1.55,
                color: kMuted,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            if (role.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 4, bottom: 24),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.red.withOpacity(0.18)),
                ),
                child: Text(
                  'Current role: $role',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Colors.redAccent,
                  ),
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Get.offAllNamed(AppRoutes.loginScreen),
                icon: const Icon(Icons.logout_rounded, size: 18),
                label: const Text(
                  'Back to Login',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 14),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Inspector Widgets
// ============================================================================

class _InspectorProfileCard extends StatelessWidget {
  final String fullName;
  final String role;
  final String email;
  final String councilName;

  const _InspectorProfileCard({
    required this.fullName,
    required this.role,
    required this.email,
    required this.councilName,
  });

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10))],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: kPrimaryGreen.withOpacity(0.10),
            child: const Icon(Icons.person, size: 30, color: kPrimaryGreen),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(fullName, style: const TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 16), overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(role, style: const TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w700, fontSize: 13)),
                const SizedBox(height: 2),
                Text(councilName, style: TextStyle(color: kMuted, fontWeight: FontWeight.w600, fontSize: 12)),
                const SizedBox(height: 2),
                Text(email, style: TextStyle(color: kMuted.withOpacity(0.8), fontWeight: FontWeight.w500, fontSize: 11), overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final int total;
  final int pending;
  final int completed;

  const _StatsGrid({required this.total, required this.pending, required this.completed});

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Total',
            value: total.toString(),
            icon: Icons.assignment_turned_in,
            color: kPrimaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Pending',
            value: pending.toString(),
            icon: Icons.pending_actions,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            title: 'Completed',
            value: completed.toString(),
            icon: Icons.check_circle,
            color: kPrimaryGreen,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({required this.title, required this.value, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontWeight: FontWeight.w900, fontSize: 22, color: color)),
          const SizedBox(height: 2),
          Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF64748B), fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _RecentInspectionsCard extends StatelessWidget {
  final List<InspectionAssignment> recentAssignments;
  final bool isLoading;
  final VoidCallback onViewAll;

  const _RecentInspectionsCard({
    required this.recentAssignments,
    required this.isLoading,
    required this.onViewAll,
  });

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: kBorder),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: kPrimaryGreen.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.assignment_late, color: kPrimaryGreen, size: 18),
              ),
              const SizedBox(width: 10),
              const Text("Recent Assignments", style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: kText)),
              const Spacer(),
              TextButton(
                onPressed: onViewAll,
                child: const Text("View all", style: TextStyle(fontWeight: FontWeight.w900, color: kPrimaryGreen)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (isLoading)
            const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()))
          else if (recentAssignments.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  children: [
                    Icon(Icons.assignment_turned_in_outlined, size: 48, color: kMuted.withOpacity(0.5)),
                    const SizedBox(height: 12),
                    Text("No assignments yet", style: TextStyle(color: kMuted, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            )
          else
            Column(
              children: recentAssignments.map((assignment) => _RecentInspectionRow(assignment: assignment)).toList(),
            ),
        ],
      ),
    );
  }
}

class _RecentInspectionRow extends StatelessWidget {
  final InspectionAssignment assignment;

  const _RecentInspectionRow({required this.assignment});

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);

  void _navigateToChecklist(BuildContext context) {
    if (assignment.isPendingInspection) {
      Get.to(() => ChecklistScreen(assignment: assignment));
    } else {
      Get.snackbar(
        'Inspection Already Completed',
        'This inspection has already been submitted and cannot be modified.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
        margin: const EdgeInsets.all(12),
        duration: const Duration(seconds: 3),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool isCompleted = assignment.isInspectionCompleted;
    final bool canNavigate = assignment.isPendingInspection;

    return InkWell(
      onTap: canNavigate ? () => _navigateToChecklist(context) : null,
      child: Opacity(
        opacity: isCompleted ? 0.6 : 1.0,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: kBorder.withOpacity(0.7))),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: assignment.formattedStatus == 'Pending'
                      ? Colors.orange.withOpacity(0.1)
                      : assignment.formattedStatus == 'Completed'
                      ? kPrimaryGreen.withOpacity(0.1)
                      : kMuted.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  assignment.formattedStatus,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    color: assignment.formattedStatus == 'Pending'
                        ? Colors.orange
                        : assignment.formattedStatus == 'Completed'
                        ? kPrimaryGreen
                        : kMuted,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: kPrimaryGreen.withOpacity(isCompleted ? 0.05 : 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  isCompleted ? Icons.check_circle : Icons.business_center,
                  size: 20,
                  color: kPrimaryGreen,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      assignment.businessName,
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: kText),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      assignment.referenceNumber,
                      style: TextStyle(fontSize: 11, color: kMuted, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              Icon(
                canNavigate ? Icons.chevron_right : Icons.lock_outline,
                size: 18,
                color: canNavigate ? kMuted : kMuted.withOpacity(0.4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}