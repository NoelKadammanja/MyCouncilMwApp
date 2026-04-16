import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/core/services/api_service.dart';
import 'package:local_govt_mw/core/services/offline_sync_service.dart';
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
  OfflineSyncService get _syncService => Get.find<OfflineSyncService>();

  List<ChecklistItem> _checklistItems = [];
  String _selectedCategory = 'All';
  List<String> _categories = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _licenseTypeName = '';
  String? _licenseTypeId;

  // Track whether checklist was loaded from cache (offline)
  bool _loadedFromCache = false;

  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback to avoid calling setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _getLicenseTypeIdAndFetchChecklist();
    });
  }

  // Safe method to show snackbars (ensures they're shown after build)
  void _showSafeSnackbar(String title, String message, {Color backgroundColor = Colors.red, int duration = 3}) {
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
    // Check if widget is still mounted
    if (!mounted) return;

    final licenseTypeId = widget.assignment.licenseTypeId;

    if (licenseTypeId == null || licenseTypeId.isEmpty) {
      if (mounted) {
        setState(() {
          _errorMessage = 'No license type ID found for this assignment.';
          _isLoading = false;
        });
      }
      _showSafeSnackbar(
        'Error',
        'This assignment does not have a license type associated with it.',
        backgroundColor: Colors.red,
      );
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
      final endpoint = '/api/v1/inspection/subcategories/full-tree/$_licenseTypeId';
      debugPrint('Fetching checklist from: $endpoint');

      final response = await _apiService.get(endpoint);
      debugPrint('Checklist API Response: $response');

      // Validate response structure before parsing
      if (response == null || !response.containsKey('categories')) {
        throw Exception('Invalid response format from server');
      }

      _parseChecklistResponse(response);
      _loadedFromCache = false;

      // Only cache if we have valid data
      if (_checklistItems.isNotEmpty) {
        await _syncService.cacheChecklist(
          _licenseTypeId!,
          _licenseTypeName,
          response,
        );
      }
    } catch (e) {
      debugPrint('Checklist API failed, trying local cache: $e');

      // Try loading from local cache
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
      } catch (cacheError) {
        debugPrint('No cached checklist available: $cacheError');
        if (mounted) {
          setState(() {
            _errorMessage = _getUserFriendlyErrorMessage(e);
          });
        }
        _showSafeSnackbar(
          'Error',
          _getUserFriendlyErrorMessage(e),
          backgroundColor: Colors.red,
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _getUserFriendlyErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();
    if (errorStr.contains('timeout') || errorStr.contains('network')) {
      return 'Network error. Please check your internet connection.';
    } else if (errorStr.contains('401') || errorStr.contains('unauthorized')) {
      return 'Session expired. Please log in again.';
    } else if (errorStr.contains('403') || errorStr.contains('forbidden')) {
      return 'You don\'t have permission to access this inspection.';
    } else if (errorStr.contains('404')) {
      return 'Checklist not found. Please contact support.';
    } else if (errorStr.contains('500')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Failed to load checklist. Please check your connection and try again.';
    }
  }

  void _parseChecklistResponse(Map<String, dynamic> response) {
    try {
      if (!response.containsKey('categories')) {
        throw Exception('Invalid response format: missing categories');
      }

      final List<dynamic> categories = response['categories'] ?? [];
      if (categories.isEmpty) {
        throw Exception('No categories found in the response');
      }

      // Safely get licenseTypeName with fallback
      _licenseTypeName = response['licenseTypeName']?.toString() ??
          response['licenseTypeId']?.toString() ??
          'Inspection';

      final List<ChecklistItem> items = [];

      for (var category in categories) {
        if (category == null) continue;

        final categoryName = category['description']?.toString() ?? 'Uncategorized';
        final List<dynamic> categoryItems = category['items'] ?? [];

        if (categoryItems.isNotEmpty) {
          for (var item in categoryItems) {
            if (item == null) continue;
            final itemId = item['id']?.toString();
            final itemDescription = item['description']?.toString();

            if (itemId == null || itemId.isEmpty) {
              debugPrint('Skipping item with missing ID: $item');
              continue;
            }

            items.add(ChecklistItem(
              id: itemId,
              title: itemDescription ?? 'Unnamed item',
              description: itemDescription ?? 'No description provided',
              selectedValue: null,
              comment: null,
              category: categoryName,
            ));
          }
        } else {
          // Handle empty category - still add as an item
          final categoryId = category['id']?.toString();
          if (categoryId != null && categoryId.isNotEmpty) {
            items.add(ChecklistItem(
              id: categoryId,
              title: categoryName,
              description: 'Check if ${categoryName.toLowerCase()} meets the required standards',
              selectedValue: null,
              comment: null,
              category: 'General',
            ));
          }
        }
      }

      if (items.isEmpty) {
        throw Exception('No checklist items found. The inspection form may be empty.');
      }

      _checklistItems = items;
      _categories = ['All', ...items.map((e) => e.category).toSet().toList()];

      debugPrint('Total checklist items loaded: ${_checklistItems.length}');
      debugPrint('Categories found: $_categories');

    } catch (e) {
      debugPrint('Error parsing checklist response: $e');
      throw Exception('Failed to parse checklist data: ${e.toString()}');
    }
  }

  int get _completedCount =>
      _checklistItems.where((item) => item.selectedValue != null).length;

  int get _totalCount => _checklistItems.length;

  double get _completionPercentage {
    if (_totalCount == 0) return 0;
    return (_completedCount / _totalCount) * 100;
  }

  bool get _canSubmit =>
      _checklistItems.isNotEmpty && _completedCount == _totalCount;

  List<ChecklistItem> get _filteredItems {
    if (_selectedCategory == 'All') return _checklistItems;
    return _checklistItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  Future<void> _submitInspection() async {
    if (!_canSubmit) {
      _showSafeSnackbar(
        'Cannot Submit',
        'Please answer all checklist items before submitting.',
        backgroundColor: Colors.orange,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
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
      );

      final requestBody = submitData.toJson();

      debugPrint('=== Submitting Inspection Results ===');
      debugPrint('Application ID: ${widget.assignment.id}');
      debugPrint('Number of results: ${results.length}');
      debugPrint('Request body: ${jsonEncode(requestBody)}');

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
        ));
      }

      if (submitResult == SubmitResult.submittedOnline) {
        _showSafeSnackbar(
          'Success',
          'Inspection results submitted successfully!',
          backgroundColor: kPrimaryGreen,
        );
      } else {
        _showSafeSnackbar(
          'Saved Offline',
          'Results saved locally. They will sync when you\'re back online.',
          backgroundColor: Colors.orange,
          duration: 5,
        );
      }
    } catch (e) {
      debugPrint('Submission error: $e');

      String errorMessage = _getSubmissionErrorMessage(e);

      _showSafeSnackbar(
        'Submission Failed',
        errorMessage,
        backgroundColor: Colors.red,
        duration: 5,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  String _getSubmissionErrorMessage(dynamic e) {
    final errorStr = e.toString().toLowerCase();
    if (errorStr.contains('500')) {
      return 'Server error. The checklist might not be valid for this application.';
    } else if (errorStr.contains('400')) {
      return 'Invalid data format. Please review your answers and try again.';
    } else if (errorStr.contains('401')) {
      return 'Session expired. Please log in again.';
    } else if (errorStr.contains('403')) {
      return 'You don\'t have permission to submit this inspection.';
    } else if (errorStr.contains('404')) {
      return 'Submission endpoint not found. Please contact support.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timed out. Please check your internet connection.';
    } else {
      return 'Failed to submit inspection results. Please try again.';
    }
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
                _checklistItems[index].comment = comment.isEmpty ? null : comment;
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
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange),
                ),
                child: const Text(
                  'OFFLINE',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: Colors.orange,
                  ),
                ),
              ),
            ),
          if (!_isLoading && _checklistItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_completedCount/$_totalCount',
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
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
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline,
                size: 64, color: Colors.red.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Failed to load checklist',
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(_errorMessage!,
                  textAlign: TextAlign.center),
            ),
            const SizedBox(height: 16),
            Text(
              'Assignment ID: ${widget.assignment.id.substring(0, 8)}...',
              style: TextStyle(fontSize: 11, color: kMuted),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _getLicenseTypeIdAndFetchChecklist,
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen),
              child: const Text('Retry'),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      )
          : _checklistItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_outlined,
                size: 64, color: kMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('No checklist items found'),
            const SizedBox(height: 8),
            Text(
                'There are no inspection items for this assignment.'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryGreen),
              child: const Text('Go Back'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          if (_loadedFromCache)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              color: Colors.orange.withOpacity(0.1),
              child: Row(
                children: [
                  const Icon(Icons.wifi_off,
                      size: 16, color: Colors.orange),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'You\'re offline. Answers will be saved locally and submitted when you reconnect.',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.orange,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Completion Progress',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: kText,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${_completionPercentage.toInt()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        color: kPrimaryGreen,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _completionPercentage / 100,
                    minHeight: 8,
                    backgroundColor: kBorder,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        kPrimaryGreen),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$_completedCount of $_totalCount items answered',
                  style: TextStyle(
                    fontSize: 12,
                    color: kMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (_categories.length > 1)
            Container(
              height: 45,
              margin: const EdgeInsets.only(bottom: 8),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding:
                const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) =>
                const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => setState(
                            () => _selectedCategory = category),
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
                      final originalItem = _checklistItems
                          .firstWhere((i) => i.id == item.id);
                      originalItem.selectedValue = value;
                    });
                  },
                  onCommentPressed: () => _showCommentDialog(item),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton(
                onPressed: _isSubmitting
                    ? null
                    : (_canSubmit ? _submitInspection : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  _canSubmit ? kPrimaryGreen : kMuted,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isSubmitting
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : Text(
                  _canSubmit
                      ? (_syncService.isOnline.value
                      ? 'Submit Inspection Report'
                      : 'Save & Sync Later')
                      : 'Complete all items (${_completedCount}/$_totalCount) to submit',
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 15,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CHECKLIST TILE WIDGET
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
          color: isAnswered ? kPrimaryGreen.withOpacity(0.3) : kBorder,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  item.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 14,
                    color: kText,
                  ),
                ),
              ),
              if (!isAnswered)
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pending',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      color: Colors.orange,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            item.description,
            style: TextStyle(
              fontSize: 12,
              color: kMuted,
              fontWeight: FontWeight.w500,
              height: 1.3,
            ),
          ),
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
                  onChanged: (value) => onValueChanged(value!),
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
                  onChanged: (value) => onValueChanged(value!),
                  activeColor: kPrimaryGreen,
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                ),
              ),
              IconButton(
                onPressed: onCommentPressed,
                icon: Icon(
                  Icons.comment_outlined,
                  size: 20,
                  color: item.comment != null && item.comment!.isNotEmpty
                      ? kPrimaryGreen
                      : kMuted,
                ),
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
                border: Border.all(color: kBorder),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.format_quote, size: 14, color: kPrimaryGreen),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item.comment!,
                      style: TextStyle(
                          fontSize: 12,
                          color: kMuted,
                          fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}