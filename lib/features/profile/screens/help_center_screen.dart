import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/common/basewidget/custom_icon_button.dart';
import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
import 'package:local_govt_mw/theme/app_decoration.dart';
import 'package:local_govt_mw/theme/app_style.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/images.dart';
import 'package:local_govt_mw/utill/size_utils.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({Key? key}) : super(key: key);

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF153871),
        body: SafeArea(
          child: SizedBox(
            width: size.width,
            child: Stack(
              children: [
                /// TOP BACKGROUND
                CustomImageView(
                  imagePath: ImageConstant.imgGroup14,
                  height: getVerticalSize(251),
                  width: getHorizontalSize(width),
                  fit: BoxFit.fill,
                  alignment: Alignment.topLeft,
                ),

                /// HEADER
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      CustomIconButton(
                        height: 50,
                        width: 50,
                        variant: IconButtonVariant.FillWhiteA70014,
                        onTap: () => Get.back(),
                        child: CustomImageView(
                          svgPath: ImageConstant.imgArrowleftWhiteA70050x50,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Terms & Conditions",
                        style: AppStyle.txtInterSemiBold20.copyWith(
                          height: getVerticalSize(1.12),
                        ),
                      ),
                    ],
                  ).paddingSymmetric(horizontal: 24),
                ),

                /// CONTENT
                Container(
                  decoration: AppDecoration.fillWhiteA700.copyWith(
                    borderRadius: BorderRadiusStyle.customBorderTL32,
                  ),
                  child: Padding(
                    padding: getPadding(top: 24),
                    child: ListView(
                      children: [
                        _section(
                          title: "1. Introduction",
                          body:
                          "These Terms and Conditions govern your use of the Local Government Revenue Collection System, developed by NICO Technologies Ltd in partnership with the Government of Malawi through the Ministry of Local Government and respective Councils (City, District, Town, and Municipal Councils).",
                        ),

                        _section(
                          title: "2. System Purpose",
                          body:
                          "This application is designed to facilitate efficient revenue collection, business licensing inspection, and management of local government services. Authorized users include revenue collectors and licensing inspectors from participating councils.",
                        ),

                        _section(
                          title: "3. User Accounts",
                          body:
                          "Access is granted only to authorized personnel of participating councils. You are responsible for maintaining the confidentiality of your login credentials and for all activities conducted under your account.",
                        ),

                        _section(
                          title: "4. Acceptable Use",
                          body:
                          "You agree to use this system solely for official council business purposes. Unauthorized access, data manipulation, or attempts to compromise system security are strictly prohibited and may result in legal action.",
                        ),

                        _section(
                          title: "5. Data Accuracy",
                          body:
                          "While NICO Technologies Ltd and partner councils strive to maintain accurate information, we do not warrant the completeness or accuracy of all data. Users should verify critical information through official channels when necessary.",
                        ),

                        _section(
                          title: "6. Intellectual Property",
                          body:
                          "The application, its code, design, and content are the intellectual property of NICO Technologies Ltd and the Government of Malawi. Unauthorized reproduction or distribution is prohibited.",
                        ),

                        _section(
                          title: "7. Limitation of Liability",
                          body:
                          "NICO Technologies Ltd and partner councils shall not be liable for any indirect, incidental, or consequential damages arising from the use or inability to use this system, including data loss or service interruptions.",
                        ),

                        _section(
                          title: "8. System Availability",
                          body:
                          "While we strive for continuous availability, we do not guarantee uninterrupted access. Scheduled maintenance or unforeseen technical issues may temporarily affect system accessibility.",
                        ),

                        _section(
                          title: "9. Amendments",
                          body:
                          "NICO Technologies Ltd reserves the right to modify these Terms and Conditions at any time. Continued use of the system after changes constitutes acceptance of the updated terms.",
                        ),

                        _section(
                          title: "10. Governing Law",
                          body:
                          "These Terms and Conditions are governed by the laws of the Republic of Malawi. Any disputes shall be resolved through the appropriate Malawian legal channels.",
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ).paddingOnly(top: getVerticalSize(118)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// -----------------------------
  Widget _section({required String title, required String body}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      color: ColorConstant.whiteA700,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppStyle.txtInterSemiBold20Gray800.copyWith(
              height: getVerticalSize(1.12),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            body,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: Color(0XFF6E758A),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}