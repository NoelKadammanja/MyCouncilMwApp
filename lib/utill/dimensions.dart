import 'package:flutter/material.dart';

/// Dimensions class for responsive sizing in the NAML app.
/// 
/// Usage:
/// ```dart
/// final isTablet = Dimensions.isTablet(context);
/// final fontSize = isTablet ? Dimensions.fontSizeLarge : Dimensions.fontSizeDefault;
/// ```
class Dimensions {
  /// Returns true if device width >= 600 (basic tablet breakpoint)
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600;
  }

  // Font sizes
  static double fontSizeExtraSmall(BuildContext context) =>
      isTablet(context) ? 14 : 10.0;
  static double fontSizeSmall(BuildContext context) =>
      isTablet(context) ? 16 : 12.0;
  static double fontSizeDefault(BuildContext context) =>
      isTablet(context) ? 18 : 14.0;
  static double fontSizeLarge(BuildContext context) =>
      isTablet(context) ? 22 : 16.0;
  static double fontSizeExtraLarge(BuildContext context) =>
      isTablet(context) ? 26 : 18.0;
  static double fontSizeOverLarge(BuildContext context) =>
      isTablet(context) ? 28 : 24.0;

  static const double fontSizeWallet = 24.0;

  // Padding sizes
  static const double paddingSizeExtraExtraSmall = 2.0;
  static const double paddingSizeExtraSmall = 5.0;
  static const double paddingSizeEight = 8.0;
  static const double paddingSizeSmall = 10.0;
  static const double paddingSizeTwelve = 12.0;
  static const double paddingSizeDefault = 15.0;
  static const double homePagePadding = 16.0;
  static const double paddingSizeDefaultAddress = 17.0;
  static const double paddingSizeLarge = 20.0;
  static const double paddingSizeExtraLarge = 25.0;
  static const double paddingSizeThirtyFive = 35.0;
  static const double paddingSizeOverLarge = 50.0;
  static const double paddingSizeExtraOverLarge = 35.0;
  static const double paddingSizeButton = 40.0;

  // Margin sizes
  static const double marginSizeExtraSmall = 5.0;
  static const double marginSizeSmall = 10.0;
  static const double marginSizeDefault = 15.0;
  static const double marginSizeLarge = 20.0;
  static const double marginSizeExtraLarge = 25.0;
  static const double marginSizeAuthSmall = 30.0;
  static const double marginSizeAuth = 50.0;

  // Icon sizes
  static const double iconSizeExtraSmall = 12.0;
  static const double iconSizeSmall = 18.0;
  static const double iconSizeDefault = 24.0;
  static const double iconSizeLarge = 32.0;
  static const double iconSizeExtraLarge = 50.0;

  // Image sizes
  static const double imageSizeExtraSeventy = 70.0;
  static const double bannerPadding = 40.0;

  // General layout dimensions
  static const double topSpace = 30.0;
  static const double splashLogoWidth = 150.0;
  static const double chooseReviewImageSize = 40.0;
  static const double profileImageSize = 100.0;
  static const double logoHeight = 80.0;
  static const double cardHeight = 265.0;

  // Corner radius
  static const double radiusSmall = 5.0;
  static const double radiusDefault = 10.0;
  static const double radiusLarge = 15.0;
  static const double radiusExtraLarge = 20.0;

  // Other UI constants
  static const double menuIconSize = 25.0;
  static const double featuredProductCard = 370.0;
  static const double compareCardWidget = 200.0;
  static const double clearanceHomeTitleHeight = 60.0;
}
