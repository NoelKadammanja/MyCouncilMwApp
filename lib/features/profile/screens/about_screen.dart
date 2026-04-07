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
                          svgPath: ImageConstant.imgArrowleftWhiteA70050x50,
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
                            'assets/images/ntech.png',
                            height: 80,
                            width: 80,
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 16),

                        Center(
                          child: Text(
                            "NICO Technologies Ltd",
                            style: AppStyle.txtInterSemiBold20Gray800,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: Text(
                            "Local Government Revenue Management System",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: const Color(0XFF6E758A),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        _section(
                          title: "Our Mission",
                          body:
                          "Offering our clients solutions that aid digital transformation.",
                        ),

                        _section(
                          title: "Our Vision",
                          body:
                          "Enabling excellent customer experience through innovative technology solutions.",
                        ),

                        _section(
                          title: "About NICO Technologies Ltd",
                          body:
                          "NICO Technologies Limited was incorporated in January 2002 under the Companies Act of Malawi. The company evolved from a self-accounting IT department of The National Insurance Company Limited, where it had been in existence since 1982.",
                        ),

                        _section(
                          title: "Our Background",
                          body:
                          "We are a purely Malawian company with strong financial backing and access to Professional Indemnity insurance cover, ensuring our commitment to service delivery. We believe in collaborating with various players locally and internationally through strategic alliances.",
                        ),

                        _section(
                          title: "About This App",
                          body:
                          "This Local Government Revenue Collection System was developed by NICO Technologies Ltd in partnership with the Government of Malawi through the Ministry of Local Government and respective Councils (City, District, Town, and Municipal Councils).",
                        ),

                        _section(
                          title: "System Purpose",
                          body:
                          "The app facilitates efficient revenue collection and business licensing inspection services. Revenue collectors can process payments from vendors and businesses, while licensing inspectors can conduct and submit inspection reports for business premises.",
                        ),

                        _section(
                          title: "Data Security",
                          body:
                          "We take data security seriously. All personal and financial information is protected using industry-standard encryption and security protocols. Access is restricted to authorized council personnel only.",
                        ),

                        _section(
                          title: "Key Features",
                          body:
                          "• Mobile revenue collection with receipt generation\n• Business licensing inspection checklists\n• Real-time assignment tracking for inspectors\n• Secure authentication and role-based access\n• Council-specific data management\n• Offline capability for field operations",
                        ),

                        _section(
                          title: "Support",
                          body:
                          "For technical support or inquiries, please contact your respective council's ICT department or reach out to NICO Technologies Ltd support team.",
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