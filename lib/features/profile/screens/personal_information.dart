import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:local_govt_mw/common/basewidget/custom_icon_button.dart';
import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
import 'package:local_govt_mw/theme/app_decoration.dart';
import 'package:local_govt_mw/theme/app_style.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/images.dart';
import 'package:local_govt_mw/utill/size_utils.dart';
import 'package:local_govt_mw/data/local/user_dao.dart';
import 'package:local_govt_mw/widgets/custom_app_bar.dart';

class PersonalInformation extends StatefulWidget {
  const PersonalInformation({Key? key}) : super(key: key);

  @override
  State<PersonalInformation> createState() => _PersonalInformationState();
}

class _PersonalInformationState extends State<PersonalInformation> {
  late final Future<Map<String, dynamic>?> userFuture;
  final TextEditingController deleteConfirmController = TextEditingController();

  @override
  void initState() {
    super.initState();
    userFuture = UserDao().getUser();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF153871),
        appBar: CustomAppBar(
          title: "Account Info",
          showBackButton: true,
        ),
        body: SafeArea(
          child: SizedBox(
            width: size.width,
            child: Stack(
              children: [
                /// CONTENT
                Stack(
                  children: [
                    Container(
                      decoration: AppDecoration.fillWhiteA700.copyWith(
                        borderRadius: BorderRadiusStyle.customBorderTL32,
                      ),
                      padding: getPadding(top: 24),
                      margin: EdgeInsets.only(top: getVerticalSize(142)),
                      child: Column(
                        children: [
                          Expanded(
                            child: FutureBuilder<Map<String, dynamic>?>(
                              future: userFuture,
                              builder: (context, snapshot) {
                                final user = snapshot.data ?? {};
                                final name =
                                    (user['name'] ?? user['full_name'])
                                        ?.toString() ??
                                        '';
                                final email = user['email']?.toString() ?? '';
                                final councilName =
                                    user['council_name']?.toString() ?? '';
                                final role = user['role']?.toString() ?? '';

                                return ListView(
                                  physics: const BouncingScrollPhysics(),
                                  children: [
                                    SizedBox(height: getVerticalSize(69)),
                                    getMyprofileDetailFormate(
                                      ImageConstant.imgProfileIcon,
                                      "Name",
                                      name.isNotEmpty ? name : "Username".tr,
                                    ),
                                    SizedBox(height: getVerticalSize(20)),
                                    const Divider(),
                                    SizedBox(height: getVerticalSize(20)),
                                    getMyprofileDetailFormate(
                                      ImageConstant.imgMailIcon,
                                      "Email",
                                      email.isNotEmpty
                                          ? email
                                          : "Useremailaddress".tr,
                                    ),
                                    SizedBox(height: getVerticalSize(20)),
                                    const Divider(),
                                    SizedBox(height: getVerticalSize(20)),
                                    getMyprofileDetailFormate(
                                      ImageConstant.imgProfileIcon,
                                      "Council",
                                      councilName.isNotEmpty ? councilName : "Council",
                                    ),
                                    SizedBox(height: getVerticalSize(20)),
                                    const Divider(),
                                    SizedBox(height: getVerticalSize(20)),
                                    getMyprofileDetailFormate(
                                      ImageConstant.imgProfileIcon,
                                      "Role",
                                      role.isNotEmpty ? role : "Role",
                                    ),
                                    SizedBox(height: getVerticalSize(24)),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// AVATAR
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
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
                              color: const Color(0XFF1C1E28).withOpacity(0.12),
                            ),
                          ],
                        ),
                        child: FutureBuilder<Map<String, dynamic>?>(
                          future: userFuture,
                          builder: (context, snapshot) {
                            final name =
                                snapshot.data?['name']?.toString() ?? '';
                            String initials = '';
                            if (name.isNotEmpty) {
                              final parts = name.split(RegExp(r"\s+"));
                              initials = parts.length == 1
                                  ? parts.first[0].toUpperCase()
                                  : (parts.first[0] + parts.last[0])
                                  .toUpperCase();
                            }

                            return CircleAvatar(
                              backgroundColor: ColorConstant.whiteA700,
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
                                imagePath: ImageConstant.imgAvtar,
                              ),
                            );
                          },
                        ),
                      ).paddingOnly(top: getVerticalSize(90)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget getMyprofileDetailFormate(
      String iconImage,
      String cetegoryName,
      String userDetail,
      ) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: getHorizontalSize(24)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CustomImageView(svgPath: iconImage),
          SizedBox(width: getHorizontalSize(16)),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  cetegoryName,
                  style: GoogleFonts.poppins(
                    color: ColorConstant.gray600,
                    fontSize: getFontSize(16),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: getVerticalSize(7)),
                Text(
                  userDetail,
                  style: GoogleFonts.poppins(
                    color: ColorConstant.black900,
                    fontSize: getFontSize(16),
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}