import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:local_govt_mw/common/basewidget/custom_button.dart';
import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
import 'package:local_govt_mw/theme/app_decoration.dart';
import 'package:local_govt_mw/theme/app_style.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:flutter/services.dart';
import 'package:local_govt_mw/utill/images.dart';
import 'package:local_govt_mw/utill/pref_utils.dart';
import 'package:local_govt_mw/utill/size_utils.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:local_govt_mw/routes/app_routes.dart';

class OtpScreen extends StatelessWidget {
  final TextEditingController otpController = TextEditingController();

  // Simulating a timer for Resend Code button
  final RxInt countdown = 48.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: ColorConstant.whiteA700,
      body: SafeArea(
        child: Container(
          height: size.height,
          width: size.width,
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              // New App Bar Design matching Setup Password screen
              Align(
                alignment: Alignment.topLeft,
                child: Container(
                  height: getVerticalSize(90.00), // Adjusted to match Setup Password AppBar height
                  width: getHorizontalSize(width),
                  padding: getPadding(left: 24, top: 16, right: 24),
                  decoration: BoxDecoration(
                    color: ColorConstant.blue700, // Consistent color with Setup Password screen
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back Button
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () {
                          Get.back();
                        },
                      ),
                      // Title
                      const Text(
                        'Enter authentication code',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // Optional icon, you can add more features here if necessary
                      IconButton(
                        icon: const Icon(Icons.help_outline, color: Colors.white),
                        onPressed: () {
                          // Help screen navigation
                        },
                      ),
                    ],
                  ),
                ),
              ),

              // Decorative top-right image
              CustomImageView(
                imagePath: ImageConstant.imgRectangle1933,
                height: getVerticalSize(175.00),
                width: getHorizontalSize(253.00),
                alignment: Alignment.topRight,
              ),

              // OTP Input and Content below the AppBar
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.only(top: 90),
                  child: Container(
                    width: size.width,
                    padding: getPadding(top: 34, bottom: 24),
                    decoration: AppDecoration.fillWhiteA700.copyWith(
                      borderRadius: BorderRadiusStyle.customBorderTL32,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Padding(
                          padding: getPadding(left: 24),
                          child: Text(
                            "Authentication code".tr,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.left,
                            style: AppStyle.txtInterBold32.copyWith(
                              height: getVerticalSize(1.01),
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.center,
                          child: Container(
                            width: getHorizontalSize(317.00),
                            margin: getMargin(top: 17),
                            child: Text(
                              "Enter the 5-digit code that we have sent to your phone number, +265 8*******23".tr,
                              maxLines: null,
                              textAlign: TextAlign.left,
                              style: AppStyle.txtInterRegular16Gray800.copyWith(
                                height: getVerticalSize(1.24),
                              ),
                            ),
                          ),
                        ),

                        // OTP PinCode field
                        Padding(
                          padding: getPadding(left: 24, top: 25, right: 24),
                          child: Obx(
                            () => PinCodeTextField(
                              appContext: context,
                              controller: otpController,
                              length: 5,
                              obscureText: false,
                              obscuringCharacter: '*',
                              keyboardType: TextInputType.number,
                              autoDismissKeyboard: true,
                              enableActiveFill: true,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly
                              ],
                              onChanged: (value) {},
                              pinTheme: PinTheme(
                                fieldHeight: getHorizontalSize(56.00),
                                fieldWidth: getHorizontalSize(56.00),
                                shape: PinCodeFieldShape.circle,
                                selectedFillColor: ColorConstant.whiteA700,
                                activeFillColor: ColorConstant.whiteA700,
                                inactiveFillColor: ColorConstant.whiteA700,
                                inactiveColor: ColorConstant.gray200,
                                selectedColor: ColorConstant.lightBlack,
                                activeColor: ColorConstant.gray200,
                              ),
                            ),
                          ),
                        ),

                        // Countdown timer display
                        Padding(
                          padding: getPadding(left: 0, top: 26),
                          child: Center(
                            child: Obx(() => RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Resend code in ".tr,
                                    style: TextStyle(
                                      color: ColorConstant.black900,
                                      fontSize: getFontSize(16),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w400,
                                      height: getVerticalSize(1.24),
                                    ),
                                  ),
                                  TextSpan(
                                   
                                    style: TextStyle(
                                      color: ColorConstant.blue700,
                                      fontSize: getFontSize(16),
                                      fontFamily: 'Inter',
                                      fontWeight: FontWeight.w700,
                                      height: getVerticalSize(1.24),
                                    ),
                                  ),
                                ],
                              ),
                            )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Continue button at bottom
              Align(
                alignment: Alignment.bottomCenter,
                child: CustomButton(
                  onTap: () {
                    PrefUtils.setIsLogin(false);
                    Get.toNamed(AppRoutes.appNavigationScreen);
                  },
                  height: 56,
                  width: 327,
                  text: "Continue".tr,
                  variant: ButtonVariant.FillNavy153871,
                  margin: getMargin(bottom: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onTapBtnArrowleft() {
    Get.back();
  }
}
