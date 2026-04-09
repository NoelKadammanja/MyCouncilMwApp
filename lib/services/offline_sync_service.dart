import 'dart:async';
import 'dart:convert';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/core/services/api_service.dart';
import 'package:local_govt_mw/data/local/database_helper.dart';

/// Central service for offline-first inspection result submission.
///
/// Responsibilities:
///  1. Save completed inspection results to SQLite when offline (or as backup).
///  2. Listen for connectivity changes and automatically retry pending submissions.
///  3. Cache assignments and checklists so inspectors can work without internet.
class OfflineSyncService extends GetxService {
  final DatabaseHelper _db = DatabaseHelper();
  ApiService get _api => Get.find<ApiService>();

  final RxInt pendingCount = 0.obs;
  final RxBool isSyncing = false.obs;
  final RxBool isOnline = true.obs;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Timer? _periodicSyncTimer;

  // ──────────────────────────────────────────────────────────────────
  // LIFECYCLE
  // ──────────────────────────────────────────────────────────────────

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    await _refreshPendingCount();
    await _startConnectivityMonitor();
    _startPeriodicSync();
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _periodicSyncTimer?.cancel();
    super.onClose();
  }

  // ──────────────────────────────────────────────────────────────────
  // CONNECTIVITY MONITORING
  // ──────────────────────────────────────────────────────────────────

  Future<void> _startConnectivityMonitor() async {
    // Check initial state
    final result = await Connectivity().checkConnectivity();
    isOnline.value = _isConnected(result);

    // Listen for changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((List<ConnectivityResult> results) async {
      final connected = _isConnected(results);
      final wasOffline = !isOnline.value;
      isOnline.value = connected;

      debugPrint('OfflineSyncService: connectivity changed → online=$connected');

      // If we just came back online, trigger sync
      if (connected && wasOffline) {
        debugPrint('OfflineSyncService: back online – triggering sync');
        await syncPendingSubmissions();
      }
    });
  }

  bool _isConnected(List<ConnectivityResult> results) {
    return results.contains(ConnectivityResult.wifi) ||
        results.contains(ConnectivityResult.mobile) ||
        results.contains(ConnectivityResult.ethernet);
  }

  Future<bool> checkConnectivity() async {
    final result = await Connectivity().checkConnectivity();
    isOnline.value = _isConnected(result);
    return isOnline.value;
  }

  // ──────────────────────────────────────────────────────────────────
  // PERIODIC SYNC (every 5 minutes while app is running)
  // ──────────────────────────────────────────────────────────────────

  void _startPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(
      const Duration(minutes: 5),
          (_) async {
        if (isOnline.value && pendingCount.value > 0) {
          await syncPendingSubmissions();
        }
      },
    );
  }

  // ──────────────────────────────────────────────────────────────────
  // PENDING COUNT
  // ──────────────────────────────────────────────────────────────────

  Future<void> _refreshPendingCount() async {
    pendingCount.value = await _db.getPendingSubmissionsCount();
  }

  // ──────────────────────────────────────────────────────────────────
  // SAVE INSPECTION RESULT LOCALLY
  // ──────────────────────────────────────────────────────────────────

  /// Save inspection results to local DB for later sync.
  /// Returns the local DB row id.
  Future<int> saveInspectionLocally({
    required String applicationId,
    required String businessName,
    required Map<String, dynamic> resultsJson,
  }) async {
    final id = await _db.savePendingSubmission(
      applicationId: applicationId,
      businessName: businessName,
      resultsJson: resultsJson,
    );
    await _refreshPendingCount();
    debugPrint(
        'OfflineSyncService: saved inspection locally, id=$id. Total pending=${pendingCount.value}');
    return id;
  }

  // ──────────────────────────────────────────────────────────────────
  // SUBMIT INSPECTION (online-first, falls back to local storage)
  // ──────────────────────────────────────────────────────────────────

  /// Try to submit directly online; if that fails due to connectivity,
  /// save locally and return [SubmitResult.savedOffline].
  Future<SubmitResult> submitInspection({
    required String applicationId,
    required String businessName,
    required Map<String, dynamic> resultsJson,
  }) async {
    final online = await checkConnectivity();

    if (online) {
      try {
        await _api.post(ApiService.submitInspectionEndpoint, resultsJson);
        debugPrint('OfflineSyncService: submitted online successfully');
        return SubmitResult.submittedOnline;
      } catch (e) {
        final msg = e.toString().toLowerCase();
        // Only fall back to local storage for network-type errors
        final isNetworkError = msg.contains('socketexception') ||
            msg.contains('timeout') ||
            msg.contains('connection') ||
            msg.contains('network') ||
            msg.contains('host') ||
            msg.contains('handshake');

        if (isNetworkError) {
          debugPrint('OfflineSyncService: network error, saving locally: $e');
          await saveInspectionLocally(
            applicationId: applicationId,
            businessName: businessName,
            resultsJson: resultsJson,
          );
          return SubmitResult.savedOffline;
        }
        // Server error (400, 500 etc.) – surface to caller
        rethrow;
      }
    } else {
      debugPrint('OfflineSyncService: offline, saving locally');
      await saveInspectionLocally(
        applicationId: applicationId,
        businessName: businessName,
        resultsJson: resultsJson,
      );
      return SubmitResult.savedOffline;
    }
  }

  // ──────────────────────────────────────────────────────────────────
  // SYNC PENDING SUBMISSIONS
  // ──────────────────────────────────────────────────────────────────

  Future<SyncSummary> syncPendingSubmissions() async {
    if (isSyncing.value) {
      debugPrint('OfflineSyncService: sync already running, skipping');
      return SyncSummary(synced: 0, failed: 0, remaining: pendingCount.value);
    }

    final online = await checkConnectivity();
    if (!online) {
      debugPrint('OfflineSyncService: still offline, skipping sync');
      return SyncSummary(synced: 0, failed: 0, remaining: pendingCount.value);
    }

    isSyncing.value = true;
    int synced = 0;
    int failed = 0;

    try {
      final pending = await _db.getPendingSubmissions();
      debugPrint('OfflineSyncService: found ${pending.length} pending submissions to sync');

      for (final submission in pending) {
        final id = submission['id'] as int;
        final applicationId = submission['application_id'] as String;

        try {
          final resultsJson =
          jsonDecode(submission['results_json'] as String) as Map<String, dynamic>;

          await _api.post(ApiService.submitInspectionEndpoint, resultsJson);
          await _db.markSubmissionSynced(id);
          synced++;

          debugPrint('OfflineSyncService: synced submission id=$id for applicationId=$applicationId');
        } catch (e) {
          failed++;
          await _db.markSubmissionFailed(id, e.toString());
          debugPrint('OfflineSyncService: failed to sync id=$id: $e');
        }
      }

      // Clean up successfully synced records
      await _db.deleteSyncedSubmissions();
    } finally {
      isSyncing.value = false;
      await _refreshPendingCount();
    }

    final summary = SyncSummary(
      synced: synced,
      failed: failed,
      remaining: pendingCount.value,
    );

    debugPrint(
        'OfflineSyncService: sync complete – synced=$synced, failed=$failed, remaining=${pendingCount.value}');

    if (synced > 0) {
      Get.snackbar(
        'Sync Complete',
        '$synced inspection${synced > 1 ? 's' : ''} synced successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF1E7F4F),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        margin: const EdgeInsets.all(12),
      );
    }

    return summary;
  }

  // ──────────────────────────────────────────────────────────────────
  // ASSIGNMENT CACHING
  // ──────────────────────────────────────────────────────────────────

  Future<void> cacheAssignments(List<Map<String, dynamic>> assignments) async {
    await _db.saveAssignments(assignments);
  }

  Future<List<Map<String, dynamic>>> getCachedAssignments() async {
    return _db.getCachedAssignments();
  }

  Future<bool> hasAssignmentCache() async {
    return _db.hasAssignmentCache();
  }

  // ──────────────────────────────────────────────────────────────────
  // CHECKLIST CACHING
  // ──────────────────────────────────────────────────────────────────

  Future<void> cacheChecklist(
      String licenseTypeId,
      String licenseTypeName,
      Map<String, dynamic> checklistData,
      ) async {
    await _db.saveChecklistCache(licenseTypeId, licenseTypeName, checklistData);
  }

  Future<Map<String, dynamic>?> getCachedChecklist(String licenseTypeId) async {
    return _db.getCachedChecklist(licenseTypeId);
  }
}

// ──────────────────────────────────────────────────────────────────
// VALUE OBJECTS
// ──────────────────────────────────────────────────────────────────

enum SubmitResult {
  submittedOnline,
  savedOffline,
}

class SyncSummary {
  final int synced;
  final int failed;
  final int remaining;

  const SyncSummary({
    required this.synced,
    required this.failed,
    required this.remaining,
  });
}