import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_govt_mw/routes/app_routes.dart';
import 'package:local_govt_mw/controllers/notifications_controller.dart';
import 'package:local_govt_mw/core/services/branding_service.dart';
import 'package:badges/badges.dart' as badges;

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final List<Widget>? actions;
  final Color? backgroundColor;
  final Color? textColor;

  // Fallback colours — used when branding hasn't loaded yet.
  static const Color _defaultStart = Color(0xFF66BB6A);
  static const Color _defaultEnd   = Color(0xFF1E7F4F);

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
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final notifController = Get.find<NotificationsController>();

    // BrandingService may not be registered on very first render
    final BrandingService? branding = Get.isRegistered<BrandingService>()
        ? Get.find<BrandingService>()
        : null;

    if (branding == null) {
      return _buildAppBar(
        context:          context,
        notifController:  notifController,
        startColor:       _defaultStart,
        endColor:         _defaultEnd,
        logoBytes:        null,
      );
    }

    return Obx(() {
      // Derive a two-stop gradient from the primary brand colour.
      // When primaryColorValue is null (not yet loaded) we fall back to
      // the default green gradient.
      final primary   = branding.primaryColorValue;
      final secondary = branding.secondaryColorValue;

      final Color start = secondary ?? (primary != null ? _lighten(primary) : _defaultStart);
      final Color end   = primary   ?? _defaultEnd;

      return _buildAppBar(
        context:         context,
        notifController: notifController,
        startColor:      start,
        endColor:        end,
        logoBytes:       branding.logoBytes.value,
      );
    });
  }

  AppBar _buildAppBar({
    required BuildContext context,
    required NotificationsController notifController,
    required Color startColor,
    required Color endColor,
    required dynamic logoBytes, // Uint8List or null
  }) {
    return AppBar(
      elevation: 0,
      centerTitle: false,
      titleSpacing: 12,
      backgroundColor: backgroundColor ?? Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [startColor, endColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      leading: showBackButton
          ? IconButton(
        icon: const Icon(Icons.arrow_back_ios,
            color: Colors.white, size: 20),
        onPressed: onBackPressed ?? () => Get.back(),
      )
          : null,
      title: Row(
        children: [
          // ── Logo: council image → fallback static asset ──────────
          SizedBox(
            width:  50,
            height: 50,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: logoBytes != null
                  ? Image.memory(
                logoBytes,
                width:  50,
                height: 50,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => _staticLogo(),
              )
                  : _staticLogo(),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                color:      textColor ?? Colors.white,
                fontSize:   18,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        Obx(() {
          final count = notifController.pendingCount.value;
          debugPrint('CustomAppBar: Building badge with count=$count');

          return GestureDetector(
            onTap: () {
              debugPrint('CustomAppBar: Notification icon tapped');
              Get.toNamed(AppRoutes.notificationScreen);
            },
            child: Container(
              margin:  const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color:        Colors.white.withOpacity(0.14),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                    color: Colors.white.withOpacity(0.22)),
              ),
              child: badges.Badge(
                showBadge: count > 0,
                badgeContent: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: GoogleFonts.poppins(
                    color:      Colors.white,
                    fontSize:   10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                badgeStyle: badges.BadgeStyle(
                  badgeColor:   Colors.red,
                  padding:      const EdgeInsets.all(4),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.notifications_none,
                  color: Colors.white,
                  size:  22,
                ),
              ),
            ),
          );
        }),
        if (actions != null) ...actions!,
      ],
    );
  }

  /// Fallback to the bundled static asset when no council logo is available.
  Widget _staticLogo() => Image.asset(
    'assets/images/mglogo.png',
    width:  40,
    height: 40,
    fit:    BoxFit.contain,
  );

  /// Lightens a colour by blending it toward white — used to derive the
  /// gradient start from the primary brand colour when no secondary is set.
  static Color _lighten(Color color, [double amount = 0.35]) {
    return Color.lerp(color, Colors.white, amount)!;
  }
}