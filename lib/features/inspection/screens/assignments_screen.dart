import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:local_govt_mw/features/inspection/controllers/assignments_controller.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';
import 'package:local_govt_mw/features/inspection/screens/checklist_screen.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';

class AssignmentsScreen extends StatelessWidget {
  const AssignmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ✅ Use Get.put here but store in a local variable — safe in StatelessWidget
    // as long as the controller isn't already registered (GetX handles dedup).
    final controller = Get.put(AssignmentsController());

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: CustomAppBar(
        title: 'Assignments',
        showBackButton: true,
        actions: [
          Obx(() {
            final isLoading = controller.isLoading.value;
            return IconButton(
              onPressed: isLoading ? null : controller.refreshAssignments,
              icon: isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.refresh, color: Colors.white),
            );
          }),
        ],
      ),
      body: Column(
        children: [
          // ✅ Filter chips
          Obx(() {
            // Read .value explicitly so Obx tracks this observable
            final selectedFilter = controller.selectedFilter.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              color: Colors.white,
              child: SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.filters.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    final filter = controller.filters[index];
                    final isSelected = selectedFilter == filter;
                    return FilterChip(
                      label: Text(filter),
                      selected: isSelected,
                      onSelected: (_) => controller.setFilter(filter),
                      backgroundColor: Colors.grey.shade50,
                      selectedColor:
                      const Color(0xFF1E7F4F).withOpacity(0.1),
                      checkmarkColor: const Color(0xFF1E7F4F),
                      labelStyle: TextStyle(
                        color: isSelected
                            ? const Color(0xFF1E7F4F)
                            : const Color(0xFF64748B),
                        fontWeight: isSelected
                            ? FontWeight.w900
                            : FontWeight.w600,
                      ),
                      side: BorderSide(
                        color: isSelected
                            ? const Color(0xFF1E7F4F)
                            : const Color(0xFFE5E7EB),
                      ),
                    );
                  },
                ),
              ),
            );
          }),

          // ✅ Assignments list
          Expanded(
            child: Obx(() {
              // ✅ Read ALL reactive variables explicitly at the top of this Obx
              final isLoading = controller.isLoading.value;
              final assignments = controller.assignments;
              final filteredAssignments = controller.filteredAssignments;
              final selectedFilter = controller.selectedFilter.value;

              if (isLoading && assignments.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }

              if (filteredAssignments.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.assignment_turned_in_outlined,
                        size: 64,
                        color: const Color(0xFF64748B).withOpacity(0.5),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        assignments.isEmpty
                            ? 'No assignments found'
                            : 'No ${selectedFilter.toLowerCase()} assignments',
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (assignments.isEmpty)
                        ElevatedButton(
                          onPressed: controller.refreshAssignments,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1E7F4F),
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Refresh'),
                        ),
                    ],
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: filteredAssignments.length,
                itemBuilder: (context, index) {
                  final assignment = filteredAssignments[index];
                  return _AssignmentCard(
                    assignment: assignment,
                    onTap: () =>
                        Get.to(() => ChecklistScreen(assignment: assignment)),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _AssignmentCard extends StatelessWidget {
  final InspectionAssignment assignment;
  final VoidCallback onTap;

  const _AssignmentCard({
    required this.assignment,
    required this.onTap,
  });

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'in progress':
        return Colors.blue;
      case 'completed':
        return kPrimaryGreen;
      case 'rejected':
        return Colors.red;
      default:
        return kMuted;
    }
  }

  String _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return '⏳';
      case 'in progress':
        return '🔄';
      case 'completed':
        return '✅';
      case 'rejected':
        return '❌';
      default:
        return '📋';
    }
  }

  IconData _getPlaceIcon(String categoryName) {
    final category = categoryName.toLowerCase();
    if (category.contains('wholesale')) {
      return Icons.storefront;
    } else if (category.contains('lodging')) {
      return Icons.hotel;
    } else if (category.contains('filling')) {
      return Icons.local_gas_station;
    } else if (category.contains('restaurant')) {
      return Icons.restaurant;
    } else if (category.contains('pharmacy')) {
      return Icons.local_pharmacy;
    } else {
      return Icons.business_center;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = assignment.formattedStatus;
    final isCompleted = status == 'Completed' || status == 'Rejected';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isCompleted ? null : onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row: icon + business name + status badge
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: kPrimaryGreen.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getPlaceIcon(assignment.categoryName),
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: kText,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            assignment.referenceNumber,
                            style: const TextStyle(
                              fontSize: 11,
                              color: kMuted,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: _getStatusColor(status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: _getStatusColor(status).withOpacity(0.2),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getStatusIcon(status),
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            status,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: _getStatusColor(status),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Owner
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: 14, color: kMuted.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        assignment.ownerName,
                        style: TextStyle(
                          fontSize: 12,
                          color: kMuted.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Category
                Row(
                  children: [
                    Icon(Icons.category,
                        size: 14, color: kMuted.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        assignment.categoryName,
                        style: TextStyle(
                          fontSize: 12,
                          color: kMuted.withOpacity(0.7),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Type
                Row(
                  children: [
                    Icon(Icons.pending_actions,
                        size: 14, color: kMuted.withOpacity(0.7)),
                    const SizedBox(width: 6),
                    Text(
                      assignment.type,
                      style: TextStyle(
                        fontSize: 12,
                        color: kMuted.withOpacity(0.7),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                // Date
                if (assignment.createdAt != null) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(Icons.calendar_today,
                          size: 14, color: kMuted.withOpacity(0.7)),
                      const SizedBox(width: 6),
                      Text(
                        'Submitted: ${DateFormat('MMM dd, yyyy').format(assignment.createdAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: kMuted.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ],

                // Start Inspection button (only for non-completed)
                if (!isCompleted) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: onTap,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Start Inspection',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}