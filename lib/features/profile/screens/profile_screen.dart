import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_govt_mw/features/profile/controllers/profile_controller.dart';
import 'package:local_govt_mw/features/profile/domain/profile_model.dart';
import 'package:local_govt_mw/features/profile/screens/about_screen.dart';
import 'package:local_govt_mw/features/profile/screens/help_center_screen.dart';
import 'package:local_govt_mw/features/profile/screens/personal_information.dart';
import 'package:local_govt_mw/routes/app_routes.dart';
import 'package:local_govt_mw/utill/pref_utils.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';
import 'package:flutter/material.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  static const Color kBg = Color(0xFFF3F4F6);
  static const Color kText = Color(0xFF0F172A);
  static const Color kMuted = Color(0xFF64748B);
  static const Color kPrimaryGreen = Color(0xFF1E7F4F);
  static const Color kBorder = Color(0xFFE5E7EB);

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController(ProfileModel().obs));
    final Future<Map<String, dynamic>?> userFuture = UserDao().getUser();

    return Scaffold(
      backgroundColor: kBg,
      appBar: CustomAppBar(
        title: "Profile",
        showBackButton: false,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: userFuture,
        builder: (context, snapshot) {
          final user = snapshot.data ?? {};
          final name = (user['name'] ?? user['full_name'])?.toString() ?? '';
          final email = user['email']?.toString() ?? '';
          final councilName = user['council_name']?.toString() ?? '';
          final role = user['role']?.toString() ?? '';

          String initials = '';
          if (name.isNotEmpty) {
            final parts = name.split(RegExp(r"\s+"));
            initials = parts.length == 1
                ? parts.first[0].toUpperCase()
                : '${parts.first[0]}${parts.last[0]}'.toUpperCase();
          }

          return ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: kBorder),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: kPrimaryGreen.withOpacity(0.1),
                      ),
                      child: Center(
                        child: initials.isNotEmpty
                            ? Text(
                          initials,
                          style: GoogleFonts.poppins(
                            color: kPrimaryGreen,
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                            : Icon(
                          Icons.person,
                          size: 50,
                          color: kPrimaryGreen,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name.isNotEmpty ? name : "User",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: kText,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      role.isNotEmpty ? role : "Role",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: kPrimaryGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      councilName.isNotEmpty ? councilName : "Council",
                      style: GoogleFonts.poppins(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: kMuted,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton(
                        onPressed: () => Get.to(() => const PersonalInformation()),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: kPrimaryGreen),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "View Account Details",
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w700,
                            color: kPrimaryGreen,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Quick Actions Section
              Text(
                "Quick Actions",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: kText,
                ),
              ),
              const SizedBox(height: 12),

              // _menuItem(
              //   icon: Icons.notifications_none,
              //   title: "App Notifications",
              //   color: const Color(0xFFF59E0B),
              //   onTap: () => Get.toNamed(AppRoutes.notificationScreen),
              // ),
              _menuItem(
                icon: Icons.language,
                title: "App Language",
                color: const Color(0xFF8B5CF6),
                onTap: () => _showLanguageDialog(context),
              ),
              const SizedBox(height: 20),

              // About Section
              Text(
                "About App",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: kText,
                ),
              ),
              const SizedBox(height: 12),

              _menuItem(
                icon: Icons.description_outlined,
                title: "Terms and Conditions",
                color: const Color(0xFF10B981),
                onTap: () => Get.to(() => const HelpCenterScreen()),
              ),
              _menuItem(
                icon: Icons.info_outline,
                title: "About Mobile App",
                color: const Color(0xFF3B82F6),
                onTap: () => Get.to(() => const AboutDinvestScreen()),
              ),
              const SizedBox(height: 20),

              // Logout Button
              _menuItem(
                icon: Icons.logout,
                title: "Logout",
                color: const Color(0xFFEF4444),
                isLogout: true,
                onTap: () => _showLogoutDialog(context),
              ),
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  Widget _menuItem({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
    bool isLogout = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorder),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 22),
        ),
        title: Text(
          title,
          style: GoogleFonts.poppins(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isLogout ? Colors.red : kText,
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: isLogout ? Colors.red : kMuted,
          size: 20,
        ),
      ),
    );
  }

  void _showLanguageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Select Language',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w900),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.check_circle, color: kPrimaryGreen),
              title: Text('English', style: GoogleFonts.poppins()),
              onTap: () => Navigator.pop(ctx),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Close', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Confirm Logout',
          style: GoogleFonts.poppins(fontWeight: FontWeight.w900),
        ),
        content: Text(
          'Are you sure you want to logout?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('No', style: GoogleFonts.poppins()),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Yes', style: GoogleFonts.poppins(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        PrefUtils.setIsLogin(false);
      } catch (_) {}
      try {
        await UserDao().clear();
      } catch (_) {}

      Get.snackbar(
        'Logged out',
        'You have been logged out successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );

      Get.offAllNamed(AppRoutes.loginScreen);
    }
  }
}