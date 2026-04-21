import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_govt_mw/routes/app_routes.dart';
import 'package:local_govt_mw/controllers/notifications_controller.dart';
import 'package:badges/badges.dart' as badges;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? textColor;

  const CustomAppBar({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.onBackPressed,
    this.actions,
    this.backgroundColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    // Get the controller
    final controller = Get.find<NotificationsController>();

    return AppBar(
      elevation: 0,
      centerTitle: false,
      titleSpacing: 12,
      backgroundColor: backgroundColor ?? Colors.transparent,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF66BB6A), Color(0xFF1E7F4F)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
        onPressed: onBackPressed ?? () => Get.back(),
      )
          : null,
      title: Row(
        children: [
          SizedBox(
            height: 40,
            child: Image.asset('assets/images/mglogo.png', fit: BoxFit.contain),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color: textColor ?? Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Obx(() {
          final count = controller.pendingCount.value;
          debugPrint('CustomAppBar: Building badge with count=$count');

          return GestureDetector(
            onTap: () {
              debugPrint('CustomAppBar: Notification icon tapped');
              Get.toNamed(AppRoutes.notificationScreen);
            },
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withOpacity(0.22)),
              ),
              child: badges.Badge(
                showBadge: count > 0,
                badgeContent: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: badges.BadgeStyle(
                  badgeColor: Colors.red,
                  padding: const EdgeInsets.all(4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          );
        }),
        if (actions != null) ...actions!,
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}