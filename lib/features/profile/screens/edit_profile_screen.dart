import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:local_govt_mw/common/basewidget/custom_button.dart';
import 'package:local_govt_mw/common/basewidget/custom_icon_button.dart';
import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
import 'package:local_govt_mw/theme/app_decoration.dart';
import 'package:local_govt_mw/theme/app_style.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/images.dart';
import 'package:local_govt_mw/utill/size_utils.dart';


class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
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
            child: Container(
              width: size.width,
              child: Stack(
                children: [
                  CustomImageView(
                    imagePath: ImageConstant.imgGroup14,
                    height: getVerticalSize(
                      251.00,
                    ),
                    width: getHorizontalSize(width),
                    fit: BoxFit.fill,
                    alignment: Alignment.topLeft,
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            CustomIconButton(
                                height: 50,
                                width: 50,
                                variant: IconButtonVariant.FillWhiteA70014,
                                onTap: () {
                                  Get.back();
                                },
                                child: CustomImageView(
                                    svgPath: ImageConstant
                                        .imgArrowleftWhiteA70050x50)),
                            SizedBox(
                              width: getHorizontalSize(68),
                            ),
                            Text("Edit Profile",
                                overflow: TextOverflow.ellipsis,
                                style: AppStyle.txtInterSemiBold20
                                    .copyWith(height: getVerticalSize(1.12))),
                          ],
                        ),
                      ],
                    ).paddingSymmetric(horizontal: getHorizontalSize(24)),
                  ),
                  Stack(
                    children: [
                      Container(
                          decoration: AppDecoration.fillWhiteA700.copyWith(
                            borderRadius: BorderRadiusStyle.customBorderTL32,
                          ),
                          child: Padding(
                            padding: getPadding(top: 24),
                            child: Column(
                              children: [
                                Expanded(
                                  child: Container(
                                    child: ListView(
                                      physics: BouncingScrollPhysics(),
                                      children: [
                                        SizedBox(
                                          height: getVerticalSize(69),
                                        ),
                                        getEditProfileOptionFormate(true,
                                            iconImage:
                                                ImageConstant.imgProfileIcon,
                                            userdetail: "Darlene Robertson",
                                            requredImage: true,
                                            hint: "Username"),
                                        SizedBox(
                                          height: getVerticalSize(20),
                                        ),
                                        getEditProfileOptionFormate(true,
                                            iconImage:
                                                ImageConstant.imgMailIcon,
                                            userdetail:
                                                "darlenerobertson@gmail.com",
                                            requredImage: true,
                                            hint: "Email id"),
                                        SizedBox(
                                          height: getVerticalSize(20),
                                        ),
                                        getEditProfileOptionFormate(true,
                                            iconImage:
                                                ImageConstant.imgCallIcon,
                                            userdetail: "(219) 555-0114",
                                            requredImage: true,
                                            hint: "Mobile number"),
                                      ],
                                    ),
                                  ),
                                ),
                                CustomButton(
                                    onTap: () => Get.back(),
                                    height: 56,
                                    width: 327,
                                    text: "Save",
                                    margin: getMargin(bottom: 30))
                              ],
                            ),
                          )).paddingOnly(top: getVerticalSize(142)),
                      Align(
                        alignment: Alignment.topCenter,
                        child: Container(
                          height: getVerticalSize(108),
                          width: getVerticalSize(108),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(32)),
                            color: ColorConstant.whiteA700,
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 20),
                                  blurRadius: 32,
                                  spreadRadius: -16,
                                  color: Color(0XFF1C1E28).withOpacity(0.12)),
                            ],
                          ),
                          child: CustomImageView(
                            imagePath: ImageConstant.imgAvtar,
                            fit: BoxFit.fill,
                          ),
                        ).paddingOnly(
                            top: getVerticalSize(90),
                            left: getHorizontalSize(0)),
                      )
                    ],
                  )
                ],
              ),
            ),
          )),
    );
  }

  Widget getEditProfileOptionFormate(bool suffixIconPosition,
      {String? iconImage,
      double? height,
      int? maxline,
      bool requredImage = true,
      String? hint,
      String? userdetail}) {
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: getHorizontalSize(24)),
        child: Container(
          height: height ?? 60,
          width: double.infinity,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                    offset: Offset(0, 4),
                    blurRadius: 16,
                    color: ColorConstant.black900.withOpacity(0.05))
              ],
              color: ColorConstant.whiteA700),
          child: TextFormField(
            maxLines: maxline ?? 1,
            initialValue: userdetail,
            decoration: InputDecoration(
                prefixIcon: Padding(
                  padding: getPadding(top: 15, bottom: 5, right: 10, left: 10),
                  child: Container(
                    child: CustomImageView(
                      svgPath: iconImage,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                border: InputBorder.none,
                hintText: hint,
                hintStyle: TextStyle(
                  color: ColorConstant.gray400,
                  fontSize: getFontSize(
                    20,
                  ),
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w500,
                ),
                contentPadding: EdgeInsets.only(
                    left: getHorizontalSize(0), top: getVerticalSize(15))),
          ),
        ));
  }
}
