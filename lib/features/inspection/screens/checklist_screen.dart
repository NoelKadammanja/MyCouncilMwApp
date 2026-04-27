import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/core/services/api_service.dart';
import 'package:local_govt_mw/core/services/location_evidence_service.dart';
import 'package:local_govt_mw/core/services/offline_sync_service.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_location_evidence.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';
import 'package:local_govt_mw/features/inspection/screens/inspection_summary_screen.dart';
import 'package:local_govt_mw/features/inspection/widgets/comment_dialog.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';

class ChecklistScreen extends StatefulWidget {
  final InspectionAssignment assignment;

  const ChecklistScreen({
    super.key,
    required this.assignment,
  });

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);
  static const Color kBg = Color(0xFFF3F4F6);

  final ApiService _apiService = ApiService();
  final LocationEvidenceService _locationService = LocationEvidenceService();
  OfflineSyncService get _syncService => Get.find<OfflineSyncService>();

  List<ChecklistItem> _checklistItems = [];
  String _selectedCategory = 'All';
  List<String> _categories = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _licenseTypeName = '';
  String? _licenseTypeId;
  bool _loadedFromCache = false;

  // ── Location evidence state ──────────────────────────────────────
  InspectionLocationEvidence? _locationEvidence;
  bool _isCapturingEvidence = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLicenseTypeIdAndFetchChecklist();
    });
  }

  void _showSafeSnackbar(
      String title,
      String message, {
        Color backgroundColor = Colors.red,
        int duration = 3,
      }) {
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          Get.snackbar(
            title,
            message,
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: backgroundColor,
            colorText: Colors.white,
            duration: Duration(seconds: duration),
            margin: const EdgeInsets.all(12),
          );
        }
      });
    }
  }

  Future<void> _getLicenseTypeIdAndFetchChecklist() async {
    if (!mounted) return;
    final licenseTypeId = widget.assignment.licenseTypeId;
    if (licenseTypeId == null || licenseTypeId.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No license type ID found for this assignment.';
          _isLoading = false;
        });
      }
      return;
    }
    _licenseTypeId = licenseTypeId;
    await _fetchChecklistFromApi();
  }

  Future<void> _fetchChecklistFromApi() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await _apiService
          .get('/api/v1/inspection/subcategories/full-tree/$_licenseTypeId');
      if (response == null || !response.containsKey('categories')) {
        throw Exception('Invalid response format from server');
      }
      _parseChecklistResponse(response);
      _loadedFromCache = false;
      if (_checklistItems.isNotEmpty) {
        await _syncService.cacheChecklist(
            _licenseTypeId!, _licenseTypeName, response);
      }
    } catch (e) {
      try {
        final cached = await _syncService.getCachedChecklist(_licenseTypeId!);
        if (cached != null && cached.containsKey('categories')) {
          _parseChecklistResponse(cached);
          _loadedFromCache = true;
          _showSafeSnackbar(
            'Offline Mode',
            'Checklist loaded from cache. Answers will sync when online.',
            backgroundColor: Colors.orange,
            duration: 4,
          );
        } else {
          throw Exception('No valid cached checklist available');
        }
      } catch (_) {
        if (mounted) {
          setState(() {
            _errorMessage = _getUserFriendlyErrorMessage(e);
          });
        }
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    final s = error.toString().toLowerCase();
    if (s.contains('timeout') || s.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (s.contains('401')) {
      return 'Session expired. Please log in again.';
    } else if (s.contains('404')) {
      return 'Checklist not found. Please contact support.';
    }
    return 'Failed to load checklist. Please check your connection and try again.';
  }

  void _parseChecklistResponse(Map<String, dynamic> response) {
    final List<dynamic> categories = response['categories'] ?? [];
    if (categories.isEmpty) throw Exception('No categories found');
    _licenseTypeName = response['licenseTypeName']?.toString() ?? 'Inspection';
    final List<ChecklistItem> items = [];
    for (var category in categories) {
      if (category == null) continue;
      final categoryName =
          category['description']?.toString() ?? 'Uncategorized';
      final List<dynamic> categoryItems = category['items'] ?? [];
      for (var item in categoryItems) {
        if (item == null) continue;
        final itemId = item['id']?.toString();
        if (itemId == null || itemId.isEmpty) continue;
        items.add(ChecklistItem(
          id: itemId,
          title: item['description']?.toString() ?? 'Unnamed item',
          description: item['description']?.toString() ?? '',
          selectedValue: null,
          comment: null,
          category: categoryName,
        ));
      }
    }
    if (items.isEmpty) throw Exception('No checklist items found.');
    _checklistItems = items;
    _categories = ['All', ...items.map((e) => e.category).toSet().toList()];
  }

  int get _completedCount =>
      _checklistItems.where((item) => item.selectedValue != null).length;
  int get _totalCount => _checklistItems.length;
  double get _completionPercentage =>
      _totalCount == 0 ? 0 : (_completedCount / _totalCount) * 100;
  bool get _canSubmit =>
      _checklistItems.isNotEmpty && _completedCount == _totalCount;
  List<ChecklistItem> get _filteredItems => _selectedCategory == 'All'
      ? _checklistItems
      : _checklistItems
      .where((item) => item.category == _selectedCategory)
      .toList();

  // ── LOCATION EVIDENCE CAPTURE ────────────────────────────────────

  /// Called when user taps Submit. Captures GPS or prompts for photo.
  Future<InspectionLocationEvidence?> _captureLocationEvidence() async {
    setState(() => _isCapturingEvidence = true);

    try {
      // 1. Try GPS first
      final position = await _locationService.tryGetGps();

      if (position != null) {
        // GPS succeeded — ask if they also want to add a photo
        final evidence = InspectionLocationEvidence(
          latitude: position.latitude,
          longitude: position.longitude,
          capturedAt: DateTime.now(),
        );

        // Optionally offer photo alongside GPS
        final addPhoto = await _showAddPhotoDialog(hasGps: true);
        if (addPhoto == true) {
          final photo = await _locationService.capturePhoto();
          if (photo != null) {
            return InspectionLocationEvidence(
              latitude: position.latitude,
              longitude: position.longitude,
              photoFile: photo,
              capturedAt: DateTime.now(),
            );
          }
        }
        return evidence;
      }

      // 2. GPS failed — require photo
      _showSafeSnackbar(
        'GPS Unavailable',
        'Location could not be determined. Please capture a site photo as evidence.',
        backgroundColor: Colors.orange,
        duration: 4,
      );

      final photo = await _showPhotoRequiredDialog();
      if (photo != null) {
        return InspectionLocationEvidence(
          photoFile: photo,
          capturedAt: DateTime.now(),
        );
      }

      return null; // User cancelled
    } finally {
      if (mounted) setState(() => _isCapturingEvidence = false);
    }
  }

  Future<bool?> _showAddPhotoDialog({required bool hasGps}) {
    return showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.location_on, color: kPrimaryGreen),
            const SizedBox(width: 8),
            const Text(
              'Location Captured',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'GPS location has been captured. Would you also like to add a timestamped photo as additional evidence?',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('No, GPS Only'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Yes, Add Photo'),
          ),
        ],
      ),
    );
  }

  Future<File?> _showPhotoRequiredDialog() async {
    final capture = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.camera_alt, color: Colors.orange),
            const SizedBox(width: 8),
            const Text(
              'Photo Required',
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        ),
        content: const Text(
          'GPS is not available. You must capture a timestamped photo of the site as evidence that you are physically present.',
          style: TextStyle(fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Open Camera'),
          ),
        ],
      ),
    );

    if (capture != true) return null;
    return _locationService.capturePhoto();
  }

  // ── SUBMIT ───────────────────────────────────────────────────────

  Future<void> _submitInspection() async {
    if (!_canSubmit) {
      _showSafeSnackbar('Cannot Submit',
          'Please answer all checklist items before submitting.',
          backgroundColor: Colors.orange);
      return;
    }

    // Step 1: Capture location evidence
    final evidence = await _captureLocationEvidence();
    if (evidence == null) {
      _showSafeSnackbar(
        'Evidence Required',
        'Location evidence (GPS or photo) is required to submit.',
        backgroundColor: Colors.red,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      InspectionLocationEvidence finalEvidence = evidence;

      // Step 2: If photo needs uploading and we're online, upload it first
      if (evidence.photoFile != null && evidence.photoFileId == null) {
        final online = await _syncService.checkConnectivity();
        if (online) {
          try {
            final photoFileId =
            await _apiService.uploadSitePhoto(evidence.photoFile!);
            finalEvidence = InspectionLocationEvidence(
              latitude: evidence.latitude,
              longitude: evidence.longitude,
              photoFile: evidence.photoFile,
              photoFileId: photoFileId,
              capturedAt: evidence.capturedAt,
            );
            debugPrint('Photo uploaded, photoFileId=$photoFileId');
          } catch (e) {
            debugPrint('Photo upload failed, will retry on sync: $e');
            // Continue with offline save — photo path stored locally
          }
        }
      }

      // Step 3: Build payload
      final results = _checklistItems.map((item) {
        return InspectionResultItem(
          checklistItemId: item.id,
          value: item.selectedValue!,
          comment: item.comment,
        );
      }).toList();

      final submitData = InspectionResultSubmit(
        applicationId: widget.assignment.id,
        results: results,
        locationEvidence: finalEvidence,
      );

      final requestBody = submitData.toJson();
      debugPrint('Submit payload: ${jsonEncode(requestBody)}');

      // Step 4: Submit (online or offline fallback)
      final submitResult = await _syncService.submitInspection(
        applicationId: widget.assignment.id,
        businessName: widget.assignment.businessName,
        resultsJson: requestBody,
      );

      final double overallRating = (_completedCount / _totalCount) * 5;
      final report = InspectionReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        assignmentId: widget.assignment.id,
        inspectionDate: DateTime.now(),
        checklist: _checklistItems,
        inspectorNotes: '',
        overallRating: overallRating,
        status: submitResult == SubmitResult.submittedOnline
            ? 'completed'
            : 'pending_sync',
      );

      if (mounted) {
        Get.off(() => InspectionSummaryScreen(
          report: report,
          placeName: widget.assignment.businessName,
          savedOffline: submitResult == SubmitResult.savedOffline,
          locationEvidence: finalEvidence,
        ));
      }
    } catch (e) {
      debugPrint('Submission error: $e');
      _showSafeSnackbar('Submission Failed', _getSubmissionErrorMessage(e),
          backgroundColor: Colors.red, duration: 5);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _getSubmissionErrorMessage(dynamic e) {
    final s = e.toString().toLowerCase();
    if (s.contains('500')) return 'Server error. Please try again later.';
    if (s.contains('400')) return 'Invalid data. Please review your answers.';
    if (s.contains('401')) return 'Session expired. Please log in again.';
    if (s.contains('timeout')) return 'Request timed out. Check your connection.';
    return 'Failed to submit inspection. Please try again.';
  }

  void _showCommentDialog(ChecklistItem item) {
    showDialog(
      context: context,
      builder: (_) => CommentDialog(
        itemTitle: item.title,
        initialComment: item.comment,
        onSave: (comment) {
          if (mounted) {
            setState(() {
              final index = _checklistItems.indexWhere((i) => i.id == item.id);
              if (index != -1) {
                _checklistItems[index].comment =
                comment.isEmpty ? null : comment;
              }
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: CustomAppBar(
        title: widget.assignment.businessName,
        showBackButton: true,
        actions: [
          if (_loadedFromCache)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text('OFFLINE',
                    style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Colors.orange)),
              ),
            ),
          if (!_isLoading && _checklistItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.check_circle, size: 16, color: Colors.white),
                  const SizedBox(width: 4),
                  Text('$_completedCount/$_totalCount',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          fontSize: 12)),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading inspection checklist...'),
          ],
        ),
      )
          : _errorMessage != null
          ? _buildErrorView()
          : _checklistItems.isEmpty
          ? _buildEmptyView()
          : _buildChecklistView(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline,
              size: 64, color: Colors.red.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Failed to load checklist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(_errorMessage!, textAlign: TextAlign.center),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _getLicenseTypeIdAndFetchChecklist,
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
            child: const Text('Retry'),
          ),
          TextButton(
              onPressed: () => Get.back(), child: const Text('Go Back')),
        ],
      ),
    );
  }

  Widget _buildEmptyView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.checklist_outlined,
              size: 64, color: kMuted.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('No checklist items found'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistView() {
    return Column(
      children: [
        // Offline banner
        if (_loadedFromCache)
          Container(
            width: double.infinity,
            padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            color: Colors.orange.withOpacity(0.1),
            child: const Row(
              children: [
                Icon(Icons.wifi_off, size: 16, color: Colors.orange),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You\'re offline. Answers will be saved locally and submitted when you reconnect.',
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),

        // Progress bar
        Container(
          margin: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Completion Progress',
                      style: TextStyle(
                          fontWeight: FontWeight.w900, fontSize: 13)),
                  Text('${_completionPercentage.toInt()}%',
                      style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: kPrimaryGreen,
                          fontSize: 13)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: _completionPercentage / 100,
                  minHeight: 8,
                  backgroundColor: kBorder,
                  valueColor:
                  const AlwaysStoppedAnimation<Color>(kPrimaryGreen),
                ),
              ),
              const SizedBox(height: 8),
              Text('$_completedCount of $_totalCount items answered',
                  style: TextStyle(
                      fontSize: 12,
                      color: kMuted,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),

        // Category filters
        if (_categories.length > 1)
          SizedBox(
            height: 45,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return FilterChip(
                  label: Text(category),
                  selected: isSelected,
                  onSelected: (_) =>
                      setState(() => _selectedCategory = category),
                  backgroundColor: Colors.white,
                  selectedColor: kPrimaryGreen.withOpacity(0.1),
                  checkmarkColor: kPrimaryGreen,
                  labelStyle: TextStyle(
                    color: isSelected ? kPrimaryGreen : kMuted,
                    fontWeight: isSelected
                        ? FontWeight.w900
                        : FontWeight.w600,
                  ),
                  side: BorderSide(
                      color: isSelected ? kPrimaryGreen : kBorder),
                );
              },
            ),
          ),

        // Checklist
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredItems.length,
            itemBuilder: (context, index) {
              final item = _filteredItems[index];
              return _ChecklistTile(
                item: item,
                onValueChanged: (value) {
                  setState(() {
                    final orig =
                    _checklistItems.firstWhere((i) => i.id == item.id);
                    orig.selectedValue = value;
                  });
                },
                onCommentPressed: () => _showCommentDialog(item),
              );
            },
          ),
        ),

        // Submit button
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2))
            ],
          ),
          child: SafeArea(
            child: ElevatedButton(
              onPressed: (_isSubmitting || _isCapturingEvidence)
                  ? null
                  : (_canSubmit ? _submitInspection : null),
              style: ElevatedButton.styleFrom(
                backgroundColor: _canSubmit ? kPrimaryGreen : kMuted,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: (_isSubmitting || _isCapturingEvidence)
                  ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                        strokeWidth: 2, color: Colors.white),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _isCapturingEvidence
                        ? 'Capturing Evidence...'
                        : 'Submitting...',
                    style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900),
                  ),
                ],
              )
                  : Text(
                _canSubmit
                    ? (_syncService.isOnline.value
                    ? 'Submit Inspection Report'
                    : 'Save & Sync Later')
                    : 'Complete all items ($_completedCount/$_totalCount) to submit',
                style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECKLIST TILE (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────

class _ChecklistTile extends StatelessWidget {
  final ChecklistItem item;
  final Function(String) onValueChanged;
  final VoidCallback onCommentPressed;

  const _ChecklistTile({
    required this.item,
    required this.onValueChanged,
    required this.onCommentPressed,
  });

  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);
  static const Color kBg = Color(0xFFF3F4F6);

  @override
  Widget build(BuildContext context) {
    final isAnswered = item.selectedValue != null;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: isAnswered ? kPrimaryGreen.withOpacity(0.3) : kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(item.title,
                    style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                        color: kText)),
              ),
              if (!isAnswered)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Text('Pending',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: Colors.orange)),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(item.description,
              style: TextStyle(
                  fontSize: 12,
                  color: kMuted,
                  fontWeight: FontWeight.w500,
                  height: 1.3)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('Yes',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  value: 'YES',
                  groupValue: item.selectedValue,
                  onChanged: (v) => onValueChanged(v!),
                  activeColor: kPrimaryGreen,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              Expanded(
                child: RadioListTile<String>(
                  title: const Text('No',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13)),
                  value: 'NO',
                  groupValue: item.selectedValue,
                  onChanged: (v) => onValueChanged(v!),
                  activeColor: kPrimaryGreen,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              IconButton(
                onPressed: onCommentPressed,
                icon: Icon(Icons.comment_outlined,
                    size: 20,
                    color:
                    item.comment != null && item.comment!.isNotEmpty
                        ? kPrimaryGreen
                        : kMuted),
                tooltip: 'Add comment',
              ),
            ],
          ),
          if (item.comment != null && item.comment!.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                  color: kBg,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: kBorder)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.format_quote,
                      size: 14, color: kPrimaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(item.comment!,
                        style: TextStyle(
                            fontSize: 12,
                            color: kMuted,
                            fontStyle: FontStyle.italic)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}