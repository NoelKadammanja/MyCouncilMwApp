import 'package:flutter/material.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/images.dart';
import 'package:local_govt_mw/utill/size_utils.dart';

class AppDecoration {
  static BoxDecoration get fillGreen5001 => BoxDecoration(
        color: ColorConstant.green5001,
      );
  static BoxDecoration get fillRedA200 => BoxDecoration(
        color: ColorConstant.redA200,
      );
  static BoxDecoration get fillLightgreen100 => BoxDecoration(
        color: ColorConstant.lightGray,
      );
  static BoxDecoration get fillLightpurple100 => BoxDecoration(
    color: ColorConstant.lightBlack,
  );
  static BoxDecoration get fillLightblue50 => BoxDecoration(
        color: ColorConstant.lightBlue50,
      );
  static BoxDecoration get fillGreen400 => BoxDecoration(
        color: ColorConstant.green400,
      );
  static BoxDecoration get fillBluegray100 => BoxDecoration(
        color: ColorConstant.blueGray100,
      );
  static BoxDecoration get outlineWhiteA700 => BoxDecoration(
        color: ColorConstant.whiteA7000f,
      );
  static BoxDecoration get txtOutlineWhiteA7004c => BoxDecoration(
        border: Border.all(
          color: ColorConstant.whiteA7004c,
          width: getHorizontalSize(
            2.00,
          ),
          // strokeAlign: StrokeAlign.center,
        ),
      );
  static BoxDecoration get fillWhiteA700ea => BoxDecoration(
        color: ColorConstant.whiteA700Ea,
      );
  static BoxDecoration get fillOrange50 => BoxDecoration(
        color: ColorConstant.orange50,
      );
  static BoxDecoration get outlineBlack9000c => BoxDecoration();
  static BoxDecoration get txtFillGreen500 => BoxDecoration(
        color: ColorConstant.green500,
    shape: BoxShape.circle
      );
  static BoxDecoration get fillGreen50 => BoxDecoration(
        color: ColorConstant.green50,
      );
  static BoxDecoration get outlineWhiteA7004c => BoxDecoration(
        border: Border.all(
          color: ColorConstant.whiteA7004c,
          width: getHorizontalSize(
            1.00,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment(
            0.88,
            0.04,
          ),
          end: Alignment(
            0.19,
            1,
          ),
          colors: [
            ColorConstant.blue700,
            ColorConstant.blue700,
          ],
        ),
      );
  static BoxDecoration get fillOrangeA200 => BoxDecoration(
        color: ColorConstant.orangeA200,
      );
  static BoxDecoration get txtFillGreen5001 => BoxDecoration(
        color: ColorConstant.green5001,
      );
  static BoxDecoration get outlineGray2001 => BoxDecoration(
        color: ColorConstant.whiteA700,
        border: Border.all(
          color: ColorConstant.gray200,
          width: getHorizontalSize(
            1.00,
          ),
        ),
      );
  static BoxDecoration get fillGray600 => BoxDecoration(
        color: ColorConstant.gray600,
      );
  static BoxDecoration get txtOutlineWhiteA700 => BoxDecoration(
        border: Border(
          top: BorderSide(
            color: ColorConstant.whiteA700,
            width: getHorizontalSize(
              1.00,
            ),
          ),
          bottom: BorderSide(
            color: ColorConstant.whiteA700,
            width: getHorizontalSize(
              1.00,
            ),
          ),
        ),
      );
  static BoxDecoration get fillYellow700 => BoxDecoration(
        color: ColorConstant.yellow700,
      );
  static BoxDecoration get outlineBlue700 => BoxDecoration(
        border: Border.all(
          color: ColorConstant.blue700,
          width: getHorizontalSize(
            1.00,
          ),
          // strokeAlign: StrokeAlign.center,
        ),
      );
  static BoxDecoration get outlineWhiteA70033 => BoxDecoration(
        border: Border.all(
          color: ColorConstant.whiteA70033,
          width: getHorizontalSize(
            2.00,
          ),
        ),
        gradient: LinearGradient(
          begin: Alignment(
            0.5,
            1,
          ),
          end: Alignment(
            0.5,
            0,
          ),
          colors: [
            ColorConstant.greenA700,
            ColorConstant.green200,
          ],
        ),
      );
  static BoxDecoration get fillWhiteA700 => BoxDecoration(
        color: ColorConstant.whiteA700,
      );
  static BoxDecoration get filllightBlue => BoxDecoration(
    color: ColorConstant.blue700.withOpacity(0.52),
  );
  //
  static BoxDecoration get fillPurple50 => BoxDecoration(
        color: ColorConstant.purple50,
      );
  static BoxDecoration get fillIndigoA100 => BoxDecoration(
        color: ColorConstant.indigoA100,
      );
  static BoxDecoration get outlineGray200 => BoxDecoration(
        color: ColorConstant.whiteA700,
        border: Border.all(
          color: ColorConstant.gray200,
          width: getHorizontalSize(
            1.00,
          ),
        ),
      );
  static BoxDecoration get fillBlue700 => BoxDecoration(
        color: ColorConstant.blue700,
      );
  static BoxDecoration get fillDeeppurpleA200 => BoxDecoration(
        color: ColorConstant.deepPurpleA200,
      );
  static BoxDecoration get fillRed400 => BoxDecoration(
        color: ColorConstant.red400,
      );
  static BoxDecoration get fillRed50 => BoxDecoration(
        color: ColorConstant.red50,
      );
  static BoxDecoration get fillBlue300 => BoxDecoration(
        color: ColorConstant.blue300,
      );
  static BoxDecoration get txtOutlineGray200 => BoxDecoration(
        color: ColorConstant.whiteA700,
        border: Border.all(
          color: ColorConstant.gray200,
          width: getHorizontalSize(
            1.00,
          ),
        ),
      );
  static BoxDecoration get fillGray100 => BoxDecoration(
        color: ColorConstant.gray100,
      );
  static BoxDecoration get fillBgColor => BoxDecoration(
    color: ColorConstant.blue700,
  );
  static BoxDecoration get txtOutlineBlue700 => BoxDecoration(
        color: ColorConstant.whiteA700,
        border: Border.all(
          color: ColorConstant.blue700,
          width: getHorizontalSize(
            1.00,
          ),
        ),
      );
  static BoxDecoration get fillLightblue900 => BoxDecoration(
        color: ColorConstant.lightBlue900,
      );
  static BoxDecoration get fillLightblue => BoxDecoration(
    color: ColorConstant.lightBlue900,
    image: DecorationImage(image: AssetImage(ImageConstant.imgGroup14),)
  );
  /*
   CustomImageView(
                        imagePath: ImageConstant.imgGroup14,
                        height: getVerticalSize(
                          251.00,
                        ),
                        width: getHorizontalSize(
                          274.00,
                        ),
                        alignment: Alignment.topLeft,
                      ),
   */
}

class BorderRadiusStyle {
  static BorderRadius txtCircleBorder28 = BorderRadius.circular(
    getHorizontalSize(
      28.00,
    ),
  );

  static BorderRadius customBorderTL13 = BorderRadius.only(
    topLeft: Radius.circular(
      getHorizontalSize(
        13.00,
      ),
    ),
    topRight: Radius.circular(
      getHorizontalSize(
        13.00,
      ),
    ),
  );

  static BorderRadius txtRoundedBorder31 = BorderRadius.circular(
    getHorizontalSize(
      31.00,
    ),
  );

  static BorderRadius customBorderTL32 = BorderRadius.only(
    topLeft: Radius.circular(
      getHorizontalSize(
        32.00,
      ),
    ),
    topRight: Radius.circular(
      getHorizontalSize(
        32.00,
      ),
    ),
  );

  static BorderRadius customBorderALL32 =BorderRadius.all(Radius.circular(32));


  static BorderRadius circleBorder28 = BorderRadius.circular(
    getHorizontalSize(
      28.00,
    ),
  );

  static BorderRadius roundedBorder16 = BorderRadius.circular(
    getHorizontalSize(
      16.00,
    ),
  );

  static BorderRadius circleBorder36 = BorderRadius.circular(
    getHorizontalSize(
      8.00,
    ),
  );

  static BorderRadius circleBorder40 = BorderRadius.circular(
    getHorizontalSize(
      40.00,
    ),
  );

  static BorderRadius roundedBorder4 = BorderRadius.circular(
    getHorizontalSize(
      4.00,
    ),
  );

  static BorderRadius roundedBorder12 = BorderRadius.circular(
    getHorizontalSize(
      12.00,
    ),
  );

  static BorderRadius roundedBorder24 = BorderRadius.circular(
    getHorizontalSize(
      8.00,
    ),
  );

  static BorderRadius roundedBorder32 = BorderRadius.circular(
    getHorizontalSize(
      32.00,
    ),
  );

  static BorderRadius circleBorder20 = BorderRadius.circular(
    getHorizontalSize(
      20.00,
    ),
  );

  static BorderRadius txtCircleBorder42 = BorderRadius.circular(
    getHorizontalSize(
      100.00,
    ),
  );

  static BorderRadius txtCircleBorder13 = BorderRadius.circular(
    getHorizontalSize(
      13.00,
    ),
  );

  static BorderRadius txtCircleBorder25 = BorderRadius.circular(
    getHorizontalSize(
      25.00,
    ),
  );
}
