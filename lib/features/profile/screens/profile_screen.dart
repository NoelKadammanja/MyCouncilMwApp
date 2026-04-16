import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
import 'package:local_govt_mw/features/profile/controllers/profile_controller.dart';
import 'package:local_govt_mw/features/profile/domain/profile_model.dart';
import 'package:local_govt_mw/features/profile/screens/about_screen.dart';
import 'package:local_govt_mw/features/profile/screens/help_center_screen.dart';
import 'package:local_govt_mw/features/profile/screens/personal_information.dart';
import 'package:local_govt_mw/routes/app_routes.dart';
import 'package:local_govt_mw/theme/app_decoration.dart';
import 'package:local_govt_mw/theme/app_style.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/images.dart';
import 'package:local_govt_mw/utill/size_utils.dart';
import 'package:local_govt_mw/utill/pref_utils.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';
import 'package:flutter/material.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';

// ignore_for_file: must_be_immutable
class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController(ProfileModel().obs));
    final Future<Map<String, dynamic>?> userFuture = UserDao().getUser();
    return WillPopScope(
      onWillPop: () async {
        Future.delayed(const Duration(milliseconds: 1000), () {
          SystemNavigator.pop();
        });
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF153871),
        body: Container(
          width: size.width,
          child: Stack(
            children: [
              CustomImageView(
                imagePath: ImageConstant.imgGroup14,
                height: getVerticalSize(251.00),
                width: getHorizontalSize(width),
                alignment: Alignment.topLeft,
              ),
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(top: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [],
                  ).paddingSymmetric(horizontal: 24),
                ),
              ),
              Padding(
                padding: getPadding(top: 20),
                child: Stack(
                  children: [
                    Container(
                      decoration: AppDecoration.fillWhiteA700.copyWith(
                        borderRadius: BorderRadiusStyle.customBorderTL32,
                      ),
                      child: Padding(
                        padding: getPadding(top: 149),
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: AppDecoration.fillGray100.copyWith(
                                  borderRadius:
                                  BorderRadiusStyle.customBorderTL32,
                                ),
                                child: Padding(
                                  padding: getPadding(top: 24),
                                  child: ListView(
                                    padding: getPadding(
                                      top: 0,
                                      left: 24,
                                      right: 24,
                                    ),
                                    physics: BouncingScrollPhysics(),
                                    children: [
                                      Text(
                                        "Quick Actions".tr,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.left,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w900,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => PersonalInformation());
                                        },
                                        child: Container(
                                          margin: getMargin(top: 16),
                                          padding: getPadding(all: 16),
                                          decoration: AppDecoration
                                              .fillWhiteA700
                                              .copyWith(
                                            borderRadius: BorderRadiusStyle
                                                .roundedBorder24,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Card(
                                                    clipBehavior:
                                                    Clip.antiAlias,
                                                    elevation: 0,
                                                    margin: EdgeInsets.all(0),
                                                    color:
                                                    ColorConstant.yellow700,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadiusStyle
                                                          .circleBorder20,
                                                    ),
                                                    child: Container(
                                                      height: getSize(40.00),
                                                      width: getSize(40.00),
                                                      padding: getPadding(
                                                        all: 8,
                                                      ),
                                                      decoration: AppDecoration
                                                          .fillYellow700
                                                          .copyWith(
                                                        borderRadius:
                                                        BorderRadiusStyle
                                                            .circleBorder20,
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          CustomImageView(
                                                            svgPath: ImageConstant
                                                                .imgUserWhiteA700,
                                                            height: getSize(
                                                              24.00,
                                                            ),
                                                            width: getSize(
                                                              24.00,
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: getPadding(
                                                      left: 12,
                                                      top: 10,
                                                      bottom: 9,
                                                    ),
                                                    child: Text(
                                                      "Account Information".tr,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              CustomImageView(
                                                svgPath:
                                                ImageConstant.imgArrowright,
                                                height: getSize(20.00),
                                                width: getSize(20.00),
                                                margin: getMargin(
                                                  top: 10,
                                                  bottom: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.toNamed(
                                            AppRoutes.notificationScreen,
                                          );
                                        },
                                        child: Container(
                                          margin: getMargin(top: 8),
                                          padding: getPadding(all: 16),
                                          decoration: AppDecoration
                                              .fillWhiteA700
                                              .copyWith(
                                            borderRadius: BorderRadiusStyle
                                                .roundedBorder24,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Card(
                                                    clipBehavior:
                                                    Clip.antiAlias,
                                                    elevation: 0,
                                                    margin: EdgeInsets.all(0),
                                                    color:
                                                    ColorConstant.redA200,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadiusStyle
                                                          .circleBorder20,
                                                    ),
                                                    child: Container(
                                                      height: getSize(40.00),
                                                      width: getSize(40.00),
                                                      padding: getPadding(
                                                        all: 8,
                                                      ),
                                                      decoration: AppDecoration
                                                          .fillRedA200
                                                          .copyWith(
                                                        borderRadius:
                                                        BorderRadiusStyle
                                                            .circleBorder20,
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          CustomImageView(
                                                            svgPath: ImageConstant
                                                                .imgNotificationWhiteA700,
                                                            height: getSize(
                                                              24.00,
                                                            ),
                                                            width: getSize(
                                                              24.00,
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: getPadding(
                                                      left: 12,
                                                      top: 10,
                                                      bottom: 9,
                                                    ),
                                                    child: Text(
                                                      "App Notifications".tr,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              CustomImageView(
                                                svgPath:
                                                ImageConstant.imgArrowright,
                                                height: getSize(20.00),
                                                width: getSize(20.00),
                                                margin: getMargin(
                                                  top: 10,
                                                  bottom: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          showDialog(
                                            context: context,
                                            barrierDismissible: true,
                                            builder: (ctx) => Dialog(
                                              insetPadding:
                                              EdgeInsets.symmetric(
                                                horizontal: 24,
                                              ),
                                              child: Padding(
                                                padding: getPadding(all: 16),
                                                child: Stack(
                                                  children: [
                                                    Column(
                                                      mainAxisSize:
                                                      MainAxisSize.min,
                                                      crossAxisAlignment:
                                                      CrossAxisAlignment
                                                          .start,
                                                      children: [
                                                        SizedBox(height: 8),
                                                        Text(
                                                          'Language'.tr,
                                                          style: GoogleFonts.poppins(
                                                            fontSize: 20,
                                                            fontWeight: FontWeight.w600,
                                                          ),
                                                        ),
                                                        SizedBox(height: 16),
                                                        Row(
                                                          children: [
                                                            Icon(
                                                              Icons.check,
                                                              color:
                                                              ColorConstant
                                                                  .blue700,
                                                            ),
                                                            SizedBox(width: 12),
                                                            Text(
                                                              'English',
                                                              style: GoogleFonts.poppins(
                                                                fontSize: 16,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        SizedBox(height: 8),
                                                      ],
                                                    ),
                                                    Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: InkWell(
                                                        onTap: () =>
                                                            Navigator.of(
                                                              ctx,
                                                            ).pop(),
                                                        child: Padding(
                                                          padding:
                                                          const EdgeInsets.all(
                                                            8.0,
                                                          ),
                                                          child: Icon(
                                                            Icons.close,
                                                            size: 20,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                        child: Container(
                                          margin: getMargin(top: 8),
                                          padding: getPadding(all: 16),
                                          decoration: AppDecoration
                                              .fillWhiteA700
                                              .copyWith(
                                            borderRadius: BorderRadiusStyle
                                                .roundedBorder24,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Card(
                                                    clipBehavior:
                                                    Clip.antiAlias,
                                                    elevation: 0,
                                                    margin: EdgeInsets.all(0),
                                                    color: ColorConstant
                                                        .deepPurpleA200,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadiusStyle
                                                          .circleBorder20,
                                                    ),
                                                    child: Container(
                                                      height: getSize(40.00),
                                                      width: getSize(40.00),
                                                      padding: getPadding(
                                                        all: 8,
                                                      ),
                                                      decoration: AppDecoration
                                                          .fillDeeppurpleA200
                                                          .copyWith(
                                                        borderRadius:
                                                        BorderRadiusStyle
                                                            .circleBorder20,
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          CustomImageView(
                                                            svgPath: ImageConstant
                                                                .imgCloseWhiteA700,
                                                            height: getSize(
                                                              24.00,
                                                            ),
                                                            width: getSize(
                                                              24.00,
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: getPadding(
                                                      left: 12,
                                                      top: 11,
                                                      bottom: 8,
                                                    ),
                                                    child: Text(
                                                      "App Language".tr,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              CustomImageView(
                                                svgPath:
                                                ImageConstant.imgArrowright,
                                                height: getSize(20.00),
                                                width: getSize(20.00),
                                                margin: getMargin(
                                                  top: 10,
                                                  bottom: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: getPadding(top: 26),
                                        child: Text(
                                          "About App".tr,
                                          overflow: TextOverflow.ellipsis,
                                          textAlign: TextAlign.left,
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w900,
                                            color: const Color(0xFF0F172A),
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => const HelpCenterScreen());
                                        },
                                        child: Container(
                                          margin: getMargin(top: 8),
                                          padding: getPadding(all: 16),
                                          decoration: AppDecoration
                                              .fillWhiteA700
                                              .copyWith(
                                            borderRadius: BorderRadiusStyle
                                                .roundedBorder24,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Card(
                                                    clipBehavior:
                                                    Clip.antiAlias,
                                                    elevation: 0,
                                                    margin: EdgeInsets.all(0),
                                                    color:
                                                    ColorConstant.green400,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadiusStyle
                                                          .circleBorder20,
                                                    ),
                                                    child: Container(
                                                      height: getSize(40.00),
                                                      width: getSize(40.00),
                                                      padding: getPadding(
                                                        all: 8,
                                                      ),
                                                      decoration: AppDecoration
                                                          .fillGreen400
                                                          .copyWith(
                                                        borderRadius:
                                                        BorderRadiusStyle
                                                            .circleBorder20,
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          CustomImageView(
                                                            svgPath:
                                                            ImageConstant
                                                                .imgQuestion,
                                                            height: getSize(
                                                              24.00,
                                                            ),
                                                            width: getSize(
                                                              24.00,
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: getPadding(
                                                      left: 12,
                                                      top: 11,
                                                      bottom: 8,
                                                    ),
                                                    child: Text(
                                                      "Terms and Conditions".tr,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              CustomImageView(
                                                svgPath:
                                                ImageConstant.imgArrowright,
                                                height: getSize(20.00),
                                                width: getSize(20.00),
                                                margin: getMargin(
                                                  top: 10,
                                                  bottom: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () {
                                          Get.to(() => const AboutDinvestScreen());
                                        },
                                        child: Container(
                                          margin: getMargin(top: 8),
                                          padding: getPadding(all: 16),
                                          decoration: AppDecoration
                                              .fillWhiteA700
                                              .copyWith(
                                            borderRadius: BorderRadiusStyle
                                                .roundedBorder24,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Card(
                                                    clipBehavior:
                                                    Clip.antiAlias,
                                                    elevation: 0,
                                                    margin: EdgeInsets.all(0),
                                                    color:
                                                    ColorConstant.blue700,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadiusStyle
                                                          .circleBorder20,
                                                    ),
                                                    child: Container(
                                                      height: getSize(40.00),
                                                      width: getSize(40.00),
                                                      padding: getPadding(
                                                        all: 8,
                                                      ),
                                                      decoration: AppDecoration
                                                          .fillBlue700
                                                          .copyWith(
                                                        borderRadius:
                                                        BorderRadiusStyle
                                                            .circleBorder20,
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          CustomImageView(
                                                            svgPath:
                                                            ImageConstant
                                                                .imgWarning,
                                                            height: getSize(
                                                              24.00,
                                                            ),
                                                            width: getSize(
                                                              24.00,
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: getPadding(
                                                      left: 12,
                                                      top: 10,
                                                      bottom: 9,
                                                    ),
                                                    child: Text(
                                                      "About Mobile App".tr,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              CustomImageView(
                                                svgPath:
                                                ImageConstant.imgArrowright,
                                                height: getSize(20.00),
                                                width: getSize(20.00),
                                                margin: getMargin(
                                                  top: 10,
                                                  bottom: 10,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: () async {
                                          final confirmed = await showDialog<bool>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text('Confirm Logout'.tr),
                                              content: Text(
                                                'Are you sure you want to logout?'
                                                    .tr,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    ctx,
                                                  ).pop(false),
                                                  child: Text('No'.tr),
                                                ),
                                                TextButton(
                                                  onPressed: () => Navigator.of(
                                                    ctx,
                                                  ).pop(true),
                                                  child: Text('Yes'.tr),
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
                                            // notify user they've logged out
                                            Get.snackbar(
                                              'Logged out',
                                              'You have been logged out successfully',
                                              snackPosition:
                                              SnackPosition.BOTTOM,
                                              backgroundColor: Colors.black87,
                                              colorText: Colors.white,
                                            );

                                            Get.offAllNamed(
                                              AppRoutes.loginScreen,
                                            );
                                          }
                                        },
                                        child: Container(
                                          margin: getMargin(top: 8, bottom: 10),
                                          padding: getPadding(all: 16),
                                          decoration: AppDecoration
                                              .fillWhiteA700
                                              .copyWith(
                                            borderRadius: BorderRadiusStyle
                                                .roundedBorder24,
                                          ),
                                          child: Row(
                                            mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Card(
                                                    clipBehavior:
                                                    Clip.antiAlias,
                                                    elevation: 0,
                                                    margin: EdgeInsets.all(0),
                                                    color: ColorConstant.red400,
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius:
                                                      BorderRadiusStyle
                                                          .circleBorder20,
                                                    ),
                                                    child: Container(
                                                      height: getSize(40.00),
                                                      width: getSize(40.00),
                                                      padding: getPadding(
                                                        all: 8,
                                                      ),
                                                      decoration: AppDecoration
                                                          .fillRed400
                                                          .copyWith(
                                                        borderRadius:
                                                        BorderRadiusStyle
                                                            .circleBorder20,
                                                      ),
                                                      child: Stack(
                                                        children: [
                                                          CustomImageView(
                                                            svgPath: ImageConstant
                                                                .imgArrowleftWhiteA700,
                                                            height: getSize(
                                                              24.00,
                                                            ),
                                                            width: getSize(
                                                              24.00,
                                                            ),
                                                            alignment: Alignment
                                                                .center,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  Padding(
                                                    padding: getPadding(
                                                      left: 12,
                                                      top: 11,
                                                      right: 188,
                                                      bottom: 8,
                                                    ),
                                                    child: Text(
                                                      "Logout".tr,
                                                      overflow:
                                                      TextOverflow.ellipsis,
                                                      textAlign: TextAlign.left,
                                                      style: GoogleFonts.poppins(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w500,
                                                        color: const Color(0xFF0F172A),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ).paddingOnly(top: getVerticalSize(142)),

                    Align(
                      alignment: Alignment.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: getVerticalSize(90),
                        ),
                        child: Column(
                          children: [
                            FutureBuilder<Map<String, dynamic>?>(
                              future: userFuture,
                              builder: (context, snapshot) {
                                final name =
                                    snapshot.data?['name']?.toString() ?? '';
                                final email =
                                    snapshot.data?['email']?.toString() ?? '';
                                final councilName =
                                    snapshot.data?['council_name']?.toString() ?? '';
                                final role =
                                    snapshot.data?['role']?.toString() ?? '';

                                String initials = '';
                                if (name.isNotEmpty) {
                                  final parts = name.split(RegExp(r"\s+"));
                                  initials = parts.length == 1
                                      ? parts.first[0].toUpperCase()
                                      : '${parts.first[0]}${parts.last[0]}'
                                      .toUpperCase();
                                }

                                return Column(
                                  children: [
                                    Container(
                                      height: getVerticalSize(108),
                                      width: getVerticalSize(108),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(32),
                                        color: ColorConstant.whiteA700,
                                        boxShadow: [
                                          BoxShadow(
                                            offset: const Offset(0, 20),
                                            blurRadius: 32,
                                            spreadRadius: -16,
                                            color: const Color(
                                              0XFF1C1E28,
                                            ).withOpacity(0.12),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        backgroundColor:
                                        ColorConstant.whiteA700,
                                        child: initials.isNotEmpty
                                            ? Text(
                                          initials,
                                          style: GoogleFonts.poppins(
                                            color: ColorConstant.blue700,
                                            fontSize: 28,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                            : CustomImageView(
                                          imagePath:
                                          ImageConstant.imgAvtar,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: getPadding(top: 16),
                                      child: Text(
                                        name.isNotEmpty ? name : "Username".tr,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF0F172A),
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: getPadding(top: 4),
                                      child: Text(
                                        councilName.isNotEmpty ? councilName : "Council".tr,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF64748B),
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: getPadding(top: 4),
                                      child: Text(
                                        role.isNotEmpty ? role : "Role".tr,
                                        overflow: TextOverflow.ellipsis,
                                        style: GoogleFonts.poppins(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: const Color(0xFF1E7F4F),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}