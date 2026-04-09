import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';
import 'package:local_govt_mw/features/inspection/screens/checklist_screen.dart';
import 'package:local_govt_mw/routes/app_routes.dart';
import 'package:local_govt_mw/features/inspection/screens/assignments_screen.dart';
import 'package:local_govt_mw/features/inspection/controllers/assignments_controller.dart';
import 'package:local_govt_mw/features/inspection/models/inspection_model.dart';

class HomepageScreen extends StatefulWidget {
  const HomepageScreen({super.key});

  @override
  State<HomepageScreen> createState() => _HomepageScreenState();
}

class _HomepageScreenState extends State<HomepageScreen> {
  // ✅ Neutral / professional palette
  static const Color kBg = Color(0xFFF3F4F6);
  static const Color kCard = Colors.white;
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);
  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kGreenSoft = Color(0xFFDCFCE7);
  static const Color kAccentGold = Color(0xFFF4C430);

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

  // Revenue collector specific data
  double dailyCollected = 135000;
  double dailyTarget = 145000;
  double weeklyRevenue = 732000;
  final List<double> weekBars = [9000, 10500, 9800, 12500, 13000, 11200];
  final List<String> weekDays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
  final List<_RecentCollection> recent = [
    _RecentCollection('ACCRU208', 'John Shaibu', 3000),
    _RecentCollection('BCGR0018', 'Thokozan Makala', 2500),
    _RecentCollection('BCGR0017', 'Chisale Barbershop', 500),
    _RecentCollection('BCGR0016', 'Tikankhe Holdings', 20000),
  ];

  // API service for inspector
  final AssignmentsController _assignmentsController = Get.put(AssignmentsController());

  // Popup state for revenue collector
  final TextEditingController _shopCodeCtrl = TextEditingController();
  final TextEditingController _vendorPhoneCtrl = TextEditingController();
  bool _lookupLoading = false;
  bool _payLoading = false;

  // API base
  static const String kApiBase = 'https://nico-customerportal.com:8083';
  static const String kPaymentInitiateUrl = 'https://nico-customerportal.com:8083/api/payments/initiate';
  static const String kValidateNumberUrl = 'https://nico-customerportal.com:8083/api/payments/validate-number';
  static const String kDefaultOwnerPhone = '0881152169';
  static const int kFallbackVendorAmount = 500;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _shopCodeCtrl.dispose();
    _vendorPhoneCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadUserProfile() async {
    try {
      final dao = UserDao();
      final user = await dao.getUser();
      if (user != null) {
        // Debug: Print all keys and values
        debugPrint('=== User Data from DAO ===');
        debugPrint('All keys: ${user.keys}');
        debugPrint('council_name: ${user['council_name']}');
        debugPrint('council: ${user['council']}');
        debugPrint('Full user: $user');

        setState(() {
          fullName = user['name']?.toString() ?? user['fullName']?.toString() ?? 'User';
          email = user['email']?.toString() ?? '';
          role = user['role']?.toString() ?? 'REVENUE_COLLECTOR';

          // Get council name from the stored value
          councilName = user['council_name']?.toString() ??
              (user['council'] as Map?)?.toString() ??
              'Council';
        });

        // Load appropriate data based on role
        if (_isInspectorRole()) {
          _loadInspectorData();
        }
      }
    } catch (e) {
      debugPrint('Error loading user profile: $e');
    }
  }

  // Helper method to check if user is an inspector
  bool _isInspectorRole() {
    return role == 'LICENSING_INSPECTOR' || role == 'INSPECTOR';
  }

  // Helper method to check if user is a revenue collector
  bool _isRevenueCollectorRole() {
    return role == 'REVENUE_COLLECTOR';
  }

  Future<void> _loadInspectorData() async {
    // Wait for assignments to load
    await Future.delayed(const Duration(milliseconds: 500));

    setState(() {
      totalAssignments = _assignmentsController.assignments.length;
      pendingAssignments = _assignmentsController.assignments
          .where((a) => a.formattedStatus == 'Pending')
          .length;
      completedAssignments = _assignmentsController.assignments
          .where((a) => a.formattedStatus == 'Completed')
          .length;

      // Get recent assignments (last 5)
      recentAssignments = _assignmentsController.assignments.take(5).toList();
    });
  }

  // Revenue collector helper methods
  String _mwk(num value) {
    final fmt = NumberFormat.currency(
      locale: 'en_US',
      symbol: 'MWK ',
      decimalDigits: 0,
    );
    return fmt.format(value);
  }

  double _pct(num part, num total) {
    if (total <= 0) return 0;
    return (part / total).clamp(0.0, 1.0).toDouble();
  }

  void _openShopCodeDialog() {
    _shopCodeCtrl.clear();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconBadge(icon: Icons.storefront),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text("Enter Stall Code",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kText)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: kMuted),
                    splashRadius: 18,
                  )
                ],
              ),
              const SizedBox(height: 10),
              const Text("Type the stall code to start collecting market fees.",
                  style: TextStyle(fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w600, color: kMuted)),
              const SizedBox(height: 14),
              TextField(
                controller: _shopCodeCtrl,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  hintText: "e.g. MKT001-ST-0001",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: kPrimaryGreen, width: 1.6),
                  ),
                  prefixIcon: const Icon(Icons.qr_code_2, color: kPrimaryGreen),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kText,
                        side: const BorderSide(color: kBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openVendorPhoneDialog() {
    _vendorPhoneCtrl.clear();
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _IconBadge(icon: Icons.phone_android),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text("Pay Mobile Vendor",
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: kText)),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, color: kMuted),
                    splashRadius: 18,
                  )
                ],
              ),
              const SizedBox(height: 10),
              const Text("Enter the vendor phone number to continue.",
                  style: TextStyle(fontSize: 12.5, height: 1.4, fontWeight: FontWeight.w600, color: kMuted)),
              const SizedBox(height: 14),
              TextField(
                controller: _vendorPhoneCtrl,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: "e.g. 0886 194 313",
                  filled: true,
                  fillColor: const Color(0xFFF8FAFC),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: kBorder)),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: kPrimaryGreen, width: 1.6),
                  ),
                  prefixIcon: const Icon(Icons.call, color: kPrimaryGreen),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: kText,
                        side: const BorderSide(color: kBorder),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Cancel", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryGreen,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: const Text("Continue", style: TextStyle(fontWeight: FontWeight.w900)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Determine which view to show based on user role
    final bool showInspectorView = _isInspectorRole();
    final bool showRevenueView = _isRevenueCollectorRole();

    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 12,
        backgroundColor: Colors.transparent,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF66BB6A), Color(0xFF1E7F4F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: SizedBox(
          height: 40,
          child: Image.asset('assets/images/mglogo.png', fit: BoxFit.contain),
        ),
        actions: [
          _appBarIcon(Icons.notifications_none,
              onTap: () => Get.toNamed(AppRoutes.notificationScreen), showDot: true),
          const SizedBox(width: 8),
          _appBarIcon(Icons.more_horiz, onTap: () {}),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        top: false,
        child: showInspectorView
            ? _buildInspectorView()
            : showRevenueView
            ? _buildRevenueCollectorView()
            : _buildDefaultView(), // Fallback for unknown roles
      ),
    );
  }

  // ===========================================================================
  // INSPECTOR VIEW
  // ===========================================================================

  Widget _buildInspectorView() {
    return Obx(() {
      // Listen to controller changes
      final isLoading = _assignmentsController.isLoading.value;
      final assignments = _assignmentsController.assignments;

      // Update statistics when assignments change
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
                    onViewAll: () => Get.to(() => const AssignmentsScreen()),
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
  // REVENUE COLLECTOR VIEW
  // ===========================================================================

  Widget _buildRevenueCollectorView() {
    final dailyProgress = _pct(dailyCollected, dailyTarget);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Column(
              children: [
                _ProfileCard(
                  officerName: fullName,
                  officerRole: 'Revenue Officer',
                  officerEmail: email,
                  marketName: 'Boma Market',
                  councilName: councilName,
                ),
                const SizedBox(height: 12),
                _QuickActionsRow(
                  onCollect: _openShopCodeDialog,
                  onPayVendor: _openVendorPhoneDialog,
                ),
                const SizedBox(height: 12),
                LayoutBuilder(
                  builder: (_, c) {
                    final sideBySide = c.maxWidth >= 520;
                    if (sideBySide) {
                      return Row(
                        children: [
                          Expanded(
                            child: _DailyCollectionsCard(
                              collected: dailyCollected,
                              target: dailyTarget,
                              progress: dailyProgress,
                              formatMoney: _mwk,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _WeeklyRevenueCard(
                              total: weeklyRevenue,
                              values: weekBars,
                              labels: weekDays,
                              formatMoney: _mwk,
                            ),
                          ),
                        ],
                      );
                    }
                    return Column(
                      children: [
                        _DailyCollectionsCard(
                          collected: dailyCollected,
                          target: dailyTarget,
                          progress: dailyProgress,
                          formatMoney: _mwk,
                        ),
                        const SizedBox(height: 12),
                        _WeeklyRevenueCard(
                          total: weeklyRevenue,
                          values: weekBars,
                          labels: weekDays,
                          formatMoney: _mwk,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 14)),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _CardShell(
              title: "Recent Collections",
              icon: Icons.receipt_long_outlined,
              trailing: TextButton(
                onPressed: () {},
                child: const Text(
                  "View all",
                  style: TextStyle(fontWeight: FontWeight.w900, color: kPrimaryGreen),
                ),
              ),
              child: Column(
                children: [
                  _tableHeader(),
                  const SizedBox(height: 6),
                  ...recent.map(_recentRow).toList(),
                ],
              ),
            ),
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }

  // ===========================================================================
  // DEFAULT VIEW (for unknown roles)
  // ===========================================================================

  Widget _buildDefaultView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.warning_amber_rounded,
            size: 64,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          Text(
            'Unauthorized Access',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              color: kText,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your role ($role) does not have access to this application.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: kMuted,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Logout and go to login screen
              Get.offAllNamed(AppRoutes.loginScreen);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Go to Login'),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // UI Helper Widgets
  // ===========================================================================

  Widget _appBarIcon(IconData icon, {VoidCallback? onTap, bool showDot = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 40,
        width: 40,
        margin: const EdgeInsets.only(top: 10, bottom: 10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.14),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withOpacity(0.22)),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 22, color: Colors.white),
            if (showDot)
              Positioned(
                right: 12,
                top: 10,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    color: Colors.redAccent,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 1.5),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _tableHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(
        color: kPrimaryGreen.withOpacity(0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kPrimaryGreen.withOpacity(0.14)),
      ),
      child: const Row(
        children: [
          SizedBox(width: 90, child: Text("Receipt", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
          Expanded(child: Text("Vendor", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
          SizedBox(width: 110, child: Text("Amount", textAlign: TextAlign.right, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900))),
        ],
      ),
    );
  }

  Widget _recentRow(_RecentCollection r) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      decoration: BoxDecoration(border: Border(bottom: BorderSide(color: kBorder.withOpacity(0.9)))),
      child: Row(
        children: [
          SizedBox(width: 90, child: Text(r.receipt, style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w800, color: kText.withOpacity(0.85)))),
          Expanded(child: Text(r.vendor, style: const TextStyle(fontSize: 12.8, fontWeight: FontWeight.w800, color: kText), overflow: TextOverflow.ellipsis)),
          SizedBox(width: 110, child: Text(_mwk(r.amount), textAlign: TextAlign.right, style: const TextStyle(fontSize: 12.8, fontWeight: FontWeight.w900, color: kText))),
        ],
      ),
    );
  }
}

// ============================================================================
// Inspector Specific Widgets
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
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kBorder = Color(0xFFE5E7EB);

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
          Text(title, style: TextStyle(fontSize: 12, color: const Color(0xFF64748B), fontWeight: FontWeight.w600)),
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
    Get.to(() => ChecklistScreen(assignment: assignment));
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _navigateToChecklist(context),
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
                  color: kPrimaryGreen.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10)
              ),
              child: Icon(Icons.business_center, size: 20, color: kPrimaryGreen),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    assignment.businessName,
                    style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        color: kText
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    assignment.referenceNumber,
                    style: TextStyle(
                        fontSize: 11,
                        color: kMuted,
                        fontWeight: FontWeight.w500
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, size: 18, color: kMuted),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Revenue Collector Widgets (Existing - kept as is)
// ============================================================================

class _IconBadge extends StatelessWidget {
  const _IconBadge({required this.icon});
  final IconData icon;
  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38, height: 38,
      decoration: BoxDecoration(color: kPrimaryGreen.withOpacity(0.10), borderRadius: BorderRadius.circular(14)),
      child: Icon(icon, color: kPrimaryGreen),
    );
  }
}

class _CardShell extends StatelessWidget {
  const _CardShell({required this.title, required this.child, required this.icon, this.trailing});
  final String title; final Widget child; final IconData icon; final Widget? trailing;
  static const Color kText = Color(0xFF0F172A); static const Color kBorder = Color(0xFFE5E7EB);
  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10))]),
      child: Column(children: [
        Row(children: [
          Container(width: 34, height: 34, decoration: BoxDecoration(color: kPrimaryGreen.withOpacity(0.10), borderRadius: BorderRadius.circular(12)),
              child: Icon(icon, color: kPrimaryGreen, size: 18)),
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w900, color: kText)),
          const Spacer(),
          if (trailing != null) trailing!,
        ]),
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.officerName, required this.officerRole, required this.officerEmail, required this.marketName, required this.councilName});
  final String officerName; final String officerRole; final String officerEmail; final String marketName; final String councilName;
  static const Color kPrimaryGreen = Color(0xFF1E7F4F); static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B); static const Color kBorder = Color(0xFFE5E7EB);
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: kBorder),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10))]),
      child: Row(children: [
        CircleAvatar(radius: 22, backgroundColor: kPrimaryGreen.withOpacity(0.10), child: const Icon(Icons.person, color: kPrimaryGreen)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(officerName, style: const TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 15.5), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text("$officerRole • $councilName", style: const TextStyle(color: kMuted, fontWeight: FontWeight.w700, fontSize: 12), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(marketName, style: TextStyle(color: kMuted.withOpacity(0.95), fontWeight: FontWeight.w700, fontSize: 12), overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(officerEmail, style: TextStyle(color: kMuted.withOpacity(0.95), fontWeight: FontWeight.w600, fontSize: 11.5), overflow: TextOverflow.ellipsis),
        ])),
        const SizedBox(width: 10),
        Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(color: kPrimaryGreen.withOpacity(0.10), borderRadius: BorderRadius.circular(999), border: Border.all(color: kPrimaryGreen.withOpacity(0.18))),
            child: const Row(children: [Icon(Icons.verified_user_outlined, size: 14, color: kPrimaryGreen), SizedBox(width: 6), Text("Active", style: TextStyle(color: kPrimaryGreen, fontWeight: FontWeight.w900, fontSize: 12))])),
      ]),
    );
  }
}

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow({required this.onCollect, required this.onPayVendor});
  final VoidCallback onCollect; final VoidCallback onPayVendor;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(child: _ActionCard(title: "Collect", subtitle: "Stall code", icon: Icons.payments_outlined, onTap: onCollect)),
      const SizedBox(width: 10),
      Expanded(child: _ActionCard(title: "Vendors", subtitle: "Phone", icon: Icons.phone_android, onTap: onPayVendor)),
    ]);
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.title, required this.subtitle, required this.icon, required this.onTap});
  final String title; final String subtitle; final IconData icon; final VoidCallback onTap;
  static const Color kPrimaryGreen = Color(0xFF1E7F4F); static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B); static const Color kBorder = Color(0xFFE5E7EB);
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, borderRadius: BorderRadius.circular(18),
      child: Container(padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: kBorder),
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 14, offset: const Offset(0, 8))]),
          child: Row(children: [
            Container(width: 42, height: 42, decoration: BoxDecoration(color: kPrimaryGreen.withOpacity(0.10), borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: kPrimaryGreen)),
            const SizedBox(width: 10),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: const TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 13.5)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(color: kMuted, fontWeight: FontWeight.w700, fontSize: 11.5)),
            ])),
            const Icon(Icons.chevron_right, color: kMuted),
          ])),
    );
  }
}

class _DailyCollectionsCard extends StatelessWidget {
  const _DailyCollectionsCard({required this.collected, required this.target, required this.progress, required this.formatMoney});
  final double collected; final double target; final double progress; final String Function(num) formatMoney;
  static const Color kPrimaryGreen = Color(0xFF1E7F4F); static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B); static const Color kBorder = Color(0xFFE5E7EB);
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: kBorder),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10))]),
        child: Row(children: [
          SizedBox(width: 72, height: 72,
              child: CustomPaint(painter: _DonutPainter(value: progress, baseColor: const Color(0xFFE5E7EB), valueColor: kPrimaryGreen, dotColor: kPrimaryGreen),
                  child: Center(child: Text("${(progress * 100).toStringAsFixed(0)}%", style: const TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 14))))),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text("Daily Collections", style: TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 13.5)),
            const SizedBox(height: 6),
            Text(formatMoney(collected), style: const TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 16)),
            const SizedBox(height: 4),
            Text("Target: ${formatMoney(target)}", style: const TextStyle(color: kMuted, fontWeight: FontWeight.w700, fontSize: 12)),
            const SizedBox(height: 10),
            ClipRRect(borderRadius: BorderRadius.circular(999),
                child: LinearProgressIndicator(value: progress, minHeight: 7, backgroundColor: const Color(0xFFE5E7EB), valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryGreen))),
          ])),
        ]));
  }
}

class _WeeklyRevenueCard extends StatelessWidget {
  const _WeeklyRevenueCard({required this.total, required this.values, required this.labels, required this.formatMoney});
  final double total; final List<double> values; final List<String> labels; final String Function(num) formatMoney;
  static const Color kPrimaryGreen = Color(0xFF1E7F4F); static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B); static const Color kBorder = Color(0xFFE5E7EB);
  @override
  Widget build(BuildContext context) {
    return Container(padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: kBorder),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 18, offset: const Offset(0, 10))]),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text("Weekly Revenue", style: TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 13.5)),
          const SizedBox(height: 6),
          Text(formatMoney(total), style: const TextStyle(color: kText, fontWeight: FontWeight.w900, fontSize: 16)),
          const SizedBox(height: 12),
          SizedBox(height: 72, child: _WeeklyBars(values: values, labels: labels, barColor: const Color(0xFFE5E7EB), highlightColor: kPrimaryGreen, labelColor: kMuted)),
        ]));
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({required this.value, required this.baseColor, required this.valueColor, required this.dotColor});
  final double value; final Color baseColor; final Color valueColor; final Color dotColor;
  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2;
    final base = Paint()..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round..color = baseColor;
    final arc = Paint()..style = PaintingStyle.stroke..strokeWidth = 10..strokeCap = StrokeCap.round..color = valueColor;
    final dot = Paint()..color = dotColor;
    canvas.drawCircle(c, r - 8, base);
    final sweep = (2 * math.pi) * value;
    final rect = Rect.fromCircle(center: c, radius: r - 8);
    canvas.drawArc(rect, -math.pi / 2, sweep, false, arc);
    final endAngle = -math.pi / 2 + sweep;
    final end = Offset(c.dx + (r - 8) * math.cos(endAngle), c.dy + (r - 8) * math.sin(endAngle));
    canvas.drawCircle(end, 2.6, dot);
  }
  @override bool shouldRepaint(covariant _DonutPainter oldDelegate) => oldDelegate.value != value || oldDelegate.baseColor != baseColor || oldDelegate.valueColor != valueColor || oldDelegate.dotColor != dotColor;
}

class _WeeklyBars extends StatelessWidget {
  const _WeeklyBars({required this.values, required this.labels, required this.barColor, required this.highlightColor, required this.labelColor});
  final List<double> values; final List<String> labels; final Color barColor; final Color highlightColor; final Color labelColor;
  @override
  Widget build(BuildContext context) {
    final maxV = values.isEmpty ? 1.0 : values.reduce(math.max);
    return Row(crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(values.length, (i) {
          final v = values[i]; final h = maxV <= 0 ? 0.0 : (v / maxV).clamp(0.0, 1.0); final isLast = i == values.length - 1;
          return Expanded(child: Padding(padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Expanded(child: Align(alignment: Alignment.bottomCenter,
                    child: FractionallySizedBox(heightFactor: h.toDouble(),
                        child: Container(decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: isLast ? highlightColor : barColor))))),
                const SizedBox(height: 6),
                Text((i < labels.length) ? labels[i] : '', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: labelColor)),
              ])));
        }));
  }
}

class _RecentCollection {
  final String receipt; final String vendor; final int amount;
  _RecentCollection(this.receipt, this.vendor, this.amount);
}