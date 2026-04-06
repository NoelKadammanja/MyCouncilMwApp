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
                          svgPath:
                              ImageConstant.imgArrowleftWhiteA70050x50,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Text(
                        "Terms & Conditions Policy",
                        
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
                          title: "1. App Usage",
                          body:
                              "By accessing or using the NICO Asset Managers mobile application, you agree to comply with these Terms and Conditions. The app is provided to allow registered clients to view investment information, balances, and related financial data for personal use only.",
                        ),

                        _section(
                          title: "2. User Responsibilities",
                          body:
                              "You are responsible for maintaining the confidentiality of your login credentials and for all activities performed under your account. You agree not to misuse the app, attempt unauthorized access, or engage in activities that may compromise the security or functionality of the system.",
                        ),

                        _section(
                          title: "3. Data Accuracy & Availability",
                          body:
                              "While NICO Asset Managers strives to ensure that all information displayed in the app is accurate and up to date, investment values may change due to market movements or system updates. Information provided through the app should not be considered as financial advice.",
                        ),

                        _section(
                          title: "4. Limitation of Liability",
                          body:
                              "NICO Asset Managers shall not be held liable for any losses arising from the use of this app, including but not limited to delays, inaccuracies, or temporary unavailability of services. Users are encouraged to contact the company directly for official confirmations.",
                        ),

                        _section(
                          title: "5. Changes to Terms",
                          body:
                              "NICO Asset Managers reserves the right to modify these Terms and Conditions at any time. Continued use of the app after changes have been made constitutes acceptance of the revised terms.",
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
