import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:local_govt_mw/common/basewidget/custom_icon_button.dart';
import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
import 'package:local_govt_mw/theme/app_decoration.dart';
import 'package:local_govt_mw/theme/app_style.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/images.dart';
import 'package:local_govt_mw/utill/size_utils.dart';

class AboutDinvestScreen extends StatefulWidget {
  const AboutDinvestScreen({Key? key}) : super(key: key);

  @override
  State<AboutDinvestScreen> createState() => _AboutDinvestScreenState();
}

class _AboutDinvestScreenState extends State<AboutDinvestScreen> {
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
                /// TOP BLUE BACKGROUND
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
                        "About App",
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
                        /// APP ICON
                        Center(
                          child: Image.asset(
                            'assets/images/icon.png',
                            height: 64,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: Text(
                            "NICO Asset Managers",
                            style: AppStyle.txtInterSemiBold20Gray800,
                          ),
                        ),

                        const SizedBox(height: 24),

                        _section(
                          title: "About NICO Asset Managers",
                          body:
                              "NICO Asset Managers Limited is a licensed investment management company offering professional asset management solutions tailored to individual and institutional investors. Our goal is to help clients grow, protect, and manage their wealth through disciplined and transparent investment strategies.",
                        ),

                        _section(
                          title: "About This App",
                          body:
                              "The NICO Asset Managers App provides clients with convenient access to their investment portfolios anytime, anywhere. Through this app, you can view balances, track performance across different asset classes, and stay informed about your investments in real time.",
                        ),

                        _section(
                          title: "Data & Security",
                          body:
                              "We take the security and confidentiality of your data seriously. All personal and financial information is handled in accordance with applicable data protection laws and industry best practices to ensure your information remains safe and secure.",
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
