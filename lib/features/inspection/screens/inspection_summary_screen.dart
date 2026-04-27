import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:local_govt_mw/core/services/location_evidence_service.dart';
import 'package:local_govt_mw/core/services/offline_sync_service.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_location_evidence.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';
import 'package:local_govt_mw/routes/app_routes.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';

class InspectionSummaryScreen extends StatelessWidget {
  final InspectionReport report;
  final String placeName;
  final bool savedOffline;
  final InspectionLocationEvidence? locationEvidence;

  const InspectionSummaryScreen({
    super.key,
    required this.report,
    required this.placeName,
    this.savedOffline = false,
    this.locationEvidence,
  });

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);
  static const Color kBg = Color(0xFFF3F4F6);

  Map<String, dynamic> _calculateStatistics() {
    final totalItems = report.checklist.length;
    final yesCount =
        report.checklist.where((item) => item.selectedValue == 'YES').length;
    final noCount =
        report.checklist.where((item) => item.selectedValue == 'NO').length;
    final yesPercentage =
    totalItems > 0 ? (yesCount / totalItems) * 100 : 0.0;
    return {
      'totalItems': totalItems,
      'yesCount': yesCount,
      'noCount': noCount,
      'yesPercentage': yesPercentage,
      'rating': (yesPercentage / 100) * 5,
      'isPassed': yesPercentage >= 90,
    };
  }

  String _getImprovementMessage(double p) {
    if (p >= 90) return 'Excellent compliance! The business meets most requirements.';
    if (p >= 75) return 'Good compliance but some improvements needed.';
    if (p >= 60) return 'Moderate compliance. Needs improvement.';
    if (p >= 20) return 'Low compliance. Major improvements required.';
    return 'Critical non-compliance. Immediate action needed.';
  }

  @override
  Widget build(BuildContext context) {
    final stats = _calculateStatistics();
    final totalItems = stats['totalItems'] as int;
    final yesCount = stats['yesCount'] as int;
    final noCount = stats['noCount'] as int;
    final yesPercentage = stats['yesPercentage'] as double;
    final rating = stats['rating'] as double;
    final isPassed = stats['isPassed'] as bool;

    return Scaffold(
      backgroundColor: kBg,
      appBar: CustomAppBar(
        title: 'Inspection Summary',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // ── Offline banner ────────────────────────────────────
            if (savedOffline)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.orange.withOpacity(0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.cloud_off, color: Colors.orange, size: 20),
                        SizedBox(width: 8),
                        Text('Saved Offline – Pending Sync',
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                                color: Colors.orange,
                                fontSize: 14)),
                      ],
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Your inspection results have been saved on this device and will be automatically submitted when internet connectivity is restored.',
                      style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                          height: 1.4),
                    ),
                    const SizedBox(height: 10),
                    Obx(() {
                      final syncService = Get.find<OfflineSyncService>();
                      return ElevatedButton.icon(
                        onPressed: syncService.isSyncing.value ||
                            !syncService.isOnline.value
                            ? null
                            : () => syncService.syncPendingSubmissions(),
                        icon: syncService.isSyncing.value
                            ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                                strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.sync, size: 16),
                        label: Text(
                          syncService.isSyncing.value
                              ? 'Syncing...'
                              : syncService.isOnline.value
                              ? 'Sync Now'
                              : 'No Connection',
                          style: const TextStyle(
                              fontWeight: FontWeight.w900, fontSize: 13),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10)),
                          elevation: 0,
                        ),
                      );
                    }),
                  ],
                ),
              ),

            // ── Location Evidence Card ────────────────────────────
            if (locationEvidence != null)
              _LocationEvidenceCard(evidence: locationEvidence!),

            const SizedBox(height: 16),

            // ── Status card ───────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: kBorder),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: (isPassed ? kPrimaryGreen : Colors.red)
                          .withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPassed ? Icons.check_circle : Icons.warning,
                      size: 50,
                      color: isPassed ? kPrimaryGreen : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isPassed ? 'PASSED' : 'NEEDS IMPROVEMENT',
                    style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 18,
                        color: isPassed ? kPrimaryGreen : Colors.red,
                        letterSpacing: 1),
                  ),
                  const SizedBox(height: 8),
                  Text(placeName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: kText)),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMMM dd, yyyy - hh:mm a')
                        .format(report.inspectionDate),
                    style: TextStyle(fontSize: 12, color: kMuted),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: kBg, borderRadius: BorderRadius.circular(12)),
                    child: Text(_getImprovementMessage(yesPercentage),
                        style:
                        TextStyle(fontSize: 13, color: kMuted, height: 1.4),
                        textAlign: TextAlign.center),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Rating & Stats card ───────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder)),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            Text(rating.toStringAsFixed(1),
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 32,
                                    color: kPrimaryGreen)),
                            const SizedBox(height: 4),
                            Text('Rating (out of 5)',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: kMuted,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Container(width: 1, height: 40, color: kBorder),
                      Expanded(
                        child: Column(
                          children: [
                            Text('${yesPercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    fontSize: 32,
                                    color: kPrimaryGreen)),
                            const SizedBox(height: 4),
                            Text('Compliance Rate',
                                style: TextStyle(
                                    fontSize: 12,
                                    color: kMuted,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(color: kBorder),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _StatCircle(
                              count: yesCount,
                              label: 'Yes',
                              sub: 'Compliant',
                              color: kPrimaryGreen)),
                      Expanded(
                          child: _StatCircle(
                              count: noCount,
                              label: 'No',
                              sub: 'Non-Compliant',
                              color: Colors.red)),
                      Expanded(
                          child: _StatCircle(
                              count: totalItems,
                              label: 'Total',
                              sub: 'Items',
                              color: kMuted)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Compliance bar ────────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Compliance Overview',
                      style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          color: kText)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (yesCount > 0)
                        Expanded(
                          flex: yesCount,
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: kPrimaryGreen,
                              borderRadius: BorderRadius.only(
                                topLeft: const Radius.circular(8),
                                bottomLeft: const Radius.circular(8),
                                topRight: noCount == 0
                                    ? const Radius.circular(8)
                                    : Radius.zero,
                                bottomRight: noCount == 0
                                    ? const Radius.circular(8)
                                    : Radius.zero,
                              ),
                            ),
                            child: Center(
                                child: Text('Yes $yesCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12))),
                          ),
                        ),
                      if (noCount > 0)
                        Expanded(
                          flex: noCount,
                          child: Container(
                            height: 30,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.only(
                                topRight: const Radius.circular(8),
                                bottomRight: const Radius.circular(8),
                                topLeft: yesCount == 0
                                    ? const Radius.circular(8)
                                    : Radius.zero,
                                bottomLeft: yesCount == 0
                                    ? const Radius.circular(8)
                                    : Radius.zero,
                              ),
                            ),
                            child: Center(
                                child: Text('No $noCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12))),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  LinearProgressIndicator(
                    value: yesPercentage / 100,
                    minHeight: 8,
                    backgroundColor: Colors.red.withOpacity(0.3),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(kPrimaryGreen),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('0%',
                          style: TextStyle(fontSize: 11, color: kMuted)),
                      Text('${yesPercentage.toStringAsFixed(0)}% Compliant',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: kPrimaryGreen)),
                      Text('100%',
                          style: TextStyle(fontSize: 11, color: kMuted)),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Detailed results ──────────────────────────────────
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.checklist,
                          size: 20, color: kPrimaryGreen),
                      const SizedBox(width: 8),
                      const Text('Detailed Results',
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              color: kText)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ...report.checklist.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              item.selectedValue == 'YES'
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              size: 18,
                              color: item.selectedValue == 'YES'
                                  ? kPrimaryGreen
                                  : Colors.red,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                CrossAxisAlignment.start,
                                children: [
                                  Text(item.title,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 13,
                                          color: kText)),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                        color: item.selectedValue == 'YES'
                                            ? kPrimaryGreen.withOpacity(0.1)
                                            : Colors.red.withOpacity(0.1),
                                        borderRadius:
                                        BorderRadius.circular(12)),
                                    child: Text(
                                        'Response: ${item.selectedValue}',
                                        style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w700,
                                            color:
                                            item.selectedValue == 'YES'
                                                ? kPrimaryGreen
                                                : Colors.red)),
                                  ),
                                  if (item.comment != null &&
                                      item.comment!.isNotEmpty)
                                    Padding(
                                      padding:
                                      const EdgeInsets.only(top: 8),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Icon(Icons.comment_outlined,
                                              size: 12, color: kMuted),
                                          const SizedBox(width: 4),
                                          Expanded(
                                              child: Text(
                                                  'Comment: ${item.comment}',
                                                  style: TextStyle(
                                                      fontSize: 11,
                                                      color: kMuted,
                                                      fontStyle:
                                                      FontStyle.italic))),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 16),
                      ],
                    ),
                  )),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ── Action buttons ────────────────────────────────────
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.homepageScreen),
                    style: OutlinedButton.styleFrom(
                        foregroundColor: kPrimaryGreen,
                        side: const BorderSide(color: kPrimaryGreen),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14))),
                    child: const Text('Back to Home',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.homepageScreen),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0),
                    child: const Text('Done',
                        style: TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LOCATION EVIDENCE CARD
// ─────────────────────────────────────────────────────────────────────────────

class _LocationEvidenceCard extends StatelessWidget {
  final InspectionLocationEvidence evidence;

  const _LocationEvidenceCard({required this.evidence});

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);
  static const Color kBg = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final locationService = LocationEvidenceService();
    final timestamp = DateFormat('dd MMM yyyy • HH:mm:ss').format(evidence.capturedAt);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.verified_user,
                    color: kPrimaryGreen, size: 20),
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('On-Site Evidence',
                        style: TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14,
                            color: kText)),
                    Text('Captured at time of inspection',
                        style: TextStyle(fontSize: 11, color: kMuted)),
                  ],
                ),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: kPrimaryGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('VERIFIED',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: kPrimaryGreen)),
              ),
            ],
          ),

          const SizedBox(height: 14),
          Divider(color: kBorder),
          const SizedBox(height: 10),

          // Timestamp
          _EvidenceRow(
            icon: Icons.access_time,
            label: 'Captured At',
            value: timestamp,
            color: kPrimaryGreen,
          ),

          const SizedBox(height: 8),

          // GPS coordinates
          if (evidence.hasGps) ...[
            _EvidenceRow(
              icon: Icons.gps_fixed,
              label: 'GPS Location',
              value: locationService.formatCoordinates(
                  evidence.latitude!, evidence.longitude!),
              color: kPrimaryGreen,
            ),
            const SizedBox(height: 8),
          ],

          // Evidence type badges
          Row(
            children: [
              if (evidence.hasGps)
                _EvidenceBadge(
                  icon: Icons.location_on,
                  label: 'GPS',
                  color: kPrimaryGreen,
                ),
              if (evidence.hasGps && evidence.hasPhoto)
                const SizedBox(width: 8),
              if (evidence.hasPhoto)
                _EvidenceBadge(
                  icon: Icons.camera_alt,
                  label: 'Photo',
                  color: Colors.blue,
                ),
            ],
          ),

          // Photo thumbnail
          if (evidence.photoFile != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Stack(
                children: [
                  Image.file(
                    evidence.photoFile!,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                  // Timestamp overlay on photo
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      color: Colors.black.withOpacity(0.6),
                      child: Row(
                        children: [
                          const Icon(Icons.access_time,
                              color: Colors.white, size: 12),
                          const SizedBox(width: 4),
                          Text(
                            timestamp,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (evidence.hasGps) ...[
                            const SizedBox(width: 10),
                            const Icon(Icons.gps_fixed,
                                color: Colors.white, size: 12),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                locationService.formatCoordinates(
                                    evidence.latitude!, evidence.longitude!),
                                style: const TextStyle(
                                    color: Colors.white, fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EvidenceRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _EvidenceRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  static const Color kMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(
                    fontSize: 10, color: kMuted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.w800)),
          ],
        ),
      ],
    );
  }
}

class _EvidenceBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _EvidenceBadge(
      {required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontSize: 11, fontWeight: FontWeight.w800, color: color)),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// STAT CIRCLE (unchanged)
// ─────────────────────────────────────────────────────────────────────────────

class _StatCircle extends StatelessWidget {
  final int count;
  final String label;
  final String sub;
  final Color color;

  const _StatCircle(
      {required this.count,
        required this.label,
        required this.sub,
        required this.color});

  static const Color kMuted = Color(0xFF64748B);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration:
          BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
          child: Center(
              child: Text('$count',
                  style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 20,
                      color: color))),
        ),
        const SizedBox(height: 8),
        Text(label,
            style: TextStyle(
                fontWeight: FontWeight.w800, fontSize: 14, color: color)),
        Text(sub, style: TextStyle(fontSize: 11, color: kMuted)),
      ],
    );
  }
}