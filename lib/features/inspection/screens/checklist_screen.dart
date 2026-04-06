import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/core/services/api_service.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';
import 'package:local_govt_mw/features/inspection/screens/inspection_summary_screen.dart';
import 'package:local_govt_mw/features/inspection/widgets/comment_dialog.dart';

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

  List<ChecklistItem> _checklistItems = [];
  String _selectedCategory = 'All';
  List<String> _categories = [];
  bool _isLoading = true;
  bool _isSubmitting = false;
  String? _errorMessage;
  String _licenseTypeName = '';
  String? _licenseTypeId;

  @override
  void initState() {
    super.initState();
    _getLicenseTypeIdAndFetchChecklist();
  }

  Future<void> _getLicenseTypeIdAndFetchChecklist() async {
    final licenseTypeId = widget.assignment.licenseTypeId;

    if (licenseTypeId == null || licenseTypeId.isEmpty) {
      setState(() {
        _errorMessage = 'No license type ID found for this assignment.';
        _isLoading = false;
      });
      Get.snackbar(
        'Error',
        'This assignment does not have a license type associated with it.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    _licenseTypeId = licenseTypeId;
    await _fetchChecklistFromApi();
  }

  Future<void> _fetchChecklistFromApi() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final endpoint = '/api/v1/inspection/subcategories/full-tree/$_licenseTypeId';
      debugPrint('Fetching checklist from: $endpoint');

      final response = await _apiService.get(endpoint);
      debugPrint('Checklist API Response: $response');

      if (response.containsKey('categories')) {
        final List<dynamic> categories = response['categories'];
        _licenseTypeName = response['licenseTypeName'] ?? 'Inspection';

        final List<ChecklistItem> items = [];

        for (var category in categories) {
          final categoryName = category['description']?.toString() ?? 'Uncategorized';
          final List<dynamic> categoryItems = category['items'] ?? [];

          if (categoryItems.isNotEmpty) {
            // For each item inside the items array, create a checklist item
            for (var item in categoryItems) {
              items.add(ChecklistItem(
                id: item['id']?.toString() ?? '', // This is the actual checklist item ID
                title: item['description']?.toString() ?? '',
                description: item['description']?.toString() ?? '',
                selectedValue: null,
                comment: null,
                category: categoryName,
              ));
            }
          } else {
            // If no items, treat the category itself as a checklist item
            items.add(ChecklistItem(
              id: category['id']?.toString() ?? '',
              title: categoryName,
              description: 'Check if ${categoryName.toLowerCase()} meets the required standards',
              selectedValue: null,
              comment: null,
              category: 'General',
            ));
          }
        }

        _checklistItems = items;
        _categories = ['All', ...items.map((e) => e.category).toSet().toList()];

        debugPrint('Total checklist items loaded: ${_checklistItems.length}');
        debugPrint('Checklist items: ${_checklistItems.map((e) => '${e.title} (${e.id})').toList()}');
      } else {
        throw Exception('Invalid response format from server');
      }
    } catch (e) {
      debugPrint('Error fetching checklist: $e');
      setState(() {
        _errorMessage = e.toString();
      });
      Get.snackbar(
        'Error',
        'Failed to load checklist. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  int get _completedCount {
    return _checklistItems.where((item) => item.selectedValue != null).length;
  }

  int get _totalCount {
    return _checklistItems.length;
  }

  double get _completionPercentage {
    if (_totalCount == 0) return 0;
    return (_completedCount / _totalCount) * 100;
  }

  bool get _canSubmit {
    return _checklistItems.isNotEmpty && _completedCount == _totalCount;
  }

  List<ChecklistItem> get _filteredItems {
    if (_selectedCategory == 'All') return _checklistItems;
    return _checklistItems
        .where((item) => item.category == _selectedCategory)
        .toList();
  }

  Future<void> _submitInspection() async {
    if (!_canSubmit) {
      Get.snackbar(
        'Cannot Submit',
        'Please answer all checklist items before submitting.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // Use InspectionResultItem model to build the results with the correct item IDs
      final results = _checklistItems.map((item) {
        return InspectionResultItem(
          checklistItemId: item.id, // This is now the ID from the items array
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

      // Log each result item for debugging
      for (var result in results) {
        debugPrint('  - Item ID: ${result.checklistItemId}, Value: ${result.value}, Comment: ${result.comment ?? 'none'}');
      }

      final response = await _apiService.post(
        ApiService.submitInspectionEndpoint,
        requestBody,
      );

      debugPrint('Submission successful! Response: $response');

      final double overallRating = (_completedCount / _totalCount) * 5;

      final report = InspectionReport(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        assignmentId: widget.assignment.id,
        inspectionDate: DateTime.now(),
        checklist: _checklistItems,
        inspectorNotes: '',
        overallRating: overallRating,
        status: 'completed',
      );

      Get.off(() => InspectionSummaryScreen(
        report: report,
        placeName: widget.assignment.businessName,
      ));

      Get.snackbar(
        'Success',
        'Inspection results submitted successfully!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: kPrimaryGreen,
        colorText: Colors.white,
      );
    } catch (e) {
      debugPrint('Submission error: $e');

      String errorMessage = 'Failed to submit inspection results. Please try again.';
      if (e.toString().contains('500')) {
        errorMessage = 'Server error. The checklist item IDs might not be valid for this application.';
      } else if (e.toString().contains('400')) {
        errorMessage = 'Invalid data format. Please review your answers and try again.';
      } else if (e.toString().contains('401')) {
        errorMessage = 'Session expired. Please log in again.';
      } else if (e.toString().contains('404')) {
        errorMessage = 'Submission endpoint not found. Please contact support.';
      }

      Get.snackbar(
        'Submission Failed',
        errorMessage,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showCommentDialog(ChecklistItem item) {
    showDialog(
      context: context,
      builder: (_) => CommentDialog(
        itemTitle: item.title,
        initialComment: item.comment,
        onSave: (comment) {
          setState(() {
            final index = _checklistItems.indexWhere((i) => i.id == item.id);
            if (index != -1) {
              _checklistItems[index].comment = comment.isEmpty ? null : comment;
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.assignment.businessName,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 18,
              ),
            ),
            Text(
              _isLoading
                  ? 'Loading checklist...'
                  : _licenseTypeId == null
                  ? 'No license type found'
                  : '$_licenseTypeName Inspection',
              style: TextStyle(
                fontSize: 12,
                color: kMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: kText,
        centerTitle: false,
        actions: [
          if (!_isLoading && _checklistItems.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(right: 16),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: kPrimaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: kPrimaryGreen,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$_completedCount/$_totalCount',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      color: kPrimaryGreen,
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
            Icon(Icons.error_outline, size: 64, color: Colors.red.withOpacity(0.5)),
            const SizedBox(height: 16),
            Text('Failed to load checklist', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(_errorMessage!, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _getLicenseTypeIdAndFetchChecklist,
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _checklistItems.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.checklist_outlined, size: 64, color: kMuted.withOpacity(0.5)),
            const SizedBox(height: 16),
            const Text('No checklist items found'),
            const SizedBox(height: 8),
            Text('There are no inspection items for license type: $_licenseTypeName'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              style: ElevatedButton.styleFrom(backgroundColor: kPrimaryGreen),
              child: const Text('Go Back'),
            ),
          ],
        ),
      )
          : Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryGreen),
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final category = _categories[index];
                  final isSelected = _selectedCategory == category;
                  return FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (_) => setState(() => _selectedCategory = category),
                    backgroundColor: Colors.white,
                    selectedColor: kPrimaryGreen.withOpacity(0.1),
                    checkmarkColor: kPrimaryGreen,
                    labelStyle: TextStyle(
                      color: isSelected ? kPrimaryGreen : kMuted,
                      fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
                    ),
                    side: BorderSide(color: isSelected ? kPrimaryGreen : kBorder),
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
                      final originalItem = _checklistItems.firstWhere((i) => i.id == item.id);
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
                onPressed: _isSubmitting ? null : (_canSubmit ? _submitInspection : null),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _canSubmit ? kPrimaryGreen : kMuted,
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
                      ? 'Submit Inspection Report'
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                  title: const Text('Yes', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                  title: const Text('No', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
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
                  color: item.comment != null && item.comment!.isNotEmpty ? kPrimaryGreen : kMuted,
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
                      style: TextStyle(fontSize: 12, color: kMuted, fontStyle: FontStyle.italic),
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