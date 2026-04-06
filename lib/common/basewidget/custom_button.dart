import 'package:flutter/material.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/size_utils.dart';

class CustomButton extends StatefulWidget {
  CustomButton({
    this.shape,
    this.padding,
    this.variant,
    this.fontStyle,
    this.alignment,
    this.margin,
    this.onTap,
    this.width,
    this.height,
    this.text,
    this.prefixWidget,
    this.suffixWidget,
  });

  final ButtonShape? shape;
  final ButtonPadding? padding;
  final ButtonVariant? variant;
  final ButtonFontStyle? fontStyle;
  final Alignment? alignment;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final double? width;
  final double? height;
  final String? text;
  final Widget? prefixWidget;
  final Widget? suffixWidget;

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> with SingleTickerProviderStateMixin {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    setState(() => _scale = 0.98);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _scale = 1.0);
  }

  void _onTapCancel() {
    setState(() => _scale = 1.0);
  }

  @override
  Widget build(BuildContext context) {
    return widget.alignment != null
        ? Align(alignment: widget.alignment!, child: _buildButtonWidget())
        : _buildButtonWidget();
  }

  Widget _buildButtonWidget() {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              decoration: BoxDecoration(
                color: _setColor(),
                borderRadius: _setBorderRadius(),
                border: _setTextButtonBorder() != null
                    ? Border.fromBorderSide(_setTextButtonBorder()!)
                    : null,
              ),
              child: InkWell(
                borderRadius: _setBorderRadius(),
                onTap: widget.onTap,
                child: Container(
                  width: getHorizontalSize(widget.width ?? 0),
                  height: getVerticalSize(widget.height ?? 0),
                  padding: _setPadding(),
                  alignment: Alignment.center,
                  child: _buildButtonWithOrWithoutIcon(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildButtonWithOrWithoutIcon() {
    if (widget.prefixWidget != null || widget.suffixWidget != null) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          widget.prefixWidget ?? const SizedBox(),
          Text(
            widget.text ?? "",
            textAlign: TextAlign.center,
            style: _setFontStyle(),
          ),
          widget.suffixWidget ?? const SizedBox(),
        ],
      );
    } else {
      return Text(
        widget.text ?? "",
        textAlign: TextAlign.center,
        style: _setFontStyle(),
      );
    }
  }

  // ignore: unused_element
  _buildTextButtonStyle() {
    return TextButton.styleFrom(
      fixedSize: Size(
        getHorizontalSize(widget.width ?? 0),
        getVerticalSize(widget.height ?? 0),
      ),
      padding: _setPadding(),
      backgroundColor: _setColor(),
      side: _setTextButtonBorder(),
      shape: RoundedRectangleBorder(
        borderRadius: _setBorderRadius(),
      ),
    );
  }

  _setPadding() {
    switch (widget.padding) {
      case ButtonPadding.PaddingT17:
        return getPadding(
          top: 17,
          right: 17,
          bottom: 17,
        );
      case ButtonPadding.PaddingT24:
        return getPadding(
          top: 24,
          right: 24,
          bottom: 24,
        );
      case ButtonPadding.PaddingAll5:
        return getPadding(
          all: 5,
        );
      case ButtonPadding.PaddingAll12:
        return getPadding(
          all: 12,
        );
      default:
        return getPadding(
          all: 17,
        );
    }
  }

  _setColor() {
    switch (widget.variant) {
      case ButtonVariant.FillNavy153871:
        return const Color(0xFF153871);
      case ButtonVariant.FillWhiteA7000f:
        return ColorConstant.lightGray;
      case ButtonVariant.darkGray16Width500:
        return ColorConstant.dartGray;
      case ButtonVariant.FillRed50:
        return ColorConstant.red50;
      case ButtonVariant.OutlineGray200:
        return ColorConstant.whiteA700;
      case ButtonVariant.FillGreen5001:
        return ColorConstant.green5001;
      case ButtonVariant.FillBlack90001:
        return ColorConstant.black90001;
      case ButtonVariant.OutlineBlue700:
      case ButtonVariant.OutlineBluegray10002:
        return null;
      default:
        return ColorConstant.blue700;
    }
  }


  _setTextButtonBorder() {
    switch (widget.variant) {
      case ButtonVariant.OutlineBlue700:
        return BorderSide(
          color: ColorConstant.blue700,
          width: getHorizontalSize(
            1.00,
          ),
        );
      case ButtonVariant.OutlineGray200:
        return BorderSide(
          color: ColorConstant.gray200,
          width: getHorizontalSize(
            1.00,
          ),
        );
      case ButtonVariant.OutlineBluegray10002:
        return BorderSide(
          color: ColorConstant.blueGray10002,
          width: getHorizontalSize(
            1.00,
          ),
        );
      default:
        return null;
        
    }
  }

  _setBorderRadius() {
    switch (widget.shape) {
      case ButtonShape.RoundedBorder24:
        return BorderRadius.circular(
          getHorizontalSize(
            8.00,
          ),
        );
      case ButtonShape.RoundedBorder16:
        return BorderRadius.circular(
          getHorizontalSize(
            16.00,
          ),
        );
      case ButtonShape.RoundedBorder13:
        return BorderRadius.circular(
          getHorizontalSize(
            13.00,
          ),
        );
      case ButtonShape.Square:
        return BorderRadius.circular(0);
      default:
        return BorderRadius.circular(
          getHorizontalSize(
            8.00,
          ),
        );
    }
  }

  _setFontStyle() {
    switch (widget.fontStyle) {
      case ButtonFontStyle.InterBold16:
        return TextStyle(
          color: ColorConstant.blue700,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        );
      case ButtonFontStyle.InterMedium16:
        return TextStyle(
          color: ColorConstant.dartGray,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        );
      case ButtonFontStyle.InterMedium16Blue700:
        return TextStyle(
          color: ColorConstant.blue700,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        );
      case ButtonFontStyle.InterRegular12:
        return TextStyle(
          color: ColorConstant.blue700,
          fontSize: getFontSize(
            12,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        );
      case ButtonFontStyle.InterMedium12:
        return TextStyle(
          color: ColorConstant.whiteA700,
          fontSize: getFontSize(
            12,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        );
      case ButtonFontStyle.InterBold20:
        return TextStyle(
          color: ColorConstant.gray800,
          fontSize: getFontSize(
            20,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        );
      case ButtonFontStyle.InterRegular12Green500:
        return TextStyle(
          color: ColorConstant.green500,
          fontSize: getFontSize(
            12,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w400,
        );
      case ButtonFontStyle.InterSemiBold14:
        return TextStyle(
          color: ColorConstant.black90001,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        );
      case ButtonFontStyle.InterSemiBold14WhiteA700:
        return TextStyle(
          color: ColorConstant.whiteA700,
          fontSize: getFontSize(
            14,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w600,
        );
      default:
        return TextStyle(
          color: ColorConstant.whiteA700,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w700,
        );
    }
  }
}

enum ButtonShape {
  Square,
  RoundedBorder28,
  RoundedBorder24,
  RoundedBorder16,
  RoundedBorder13,
}
enum ButtonPadding {
  PaddingAll17,
  PaddingT17,
  PaddingT24,
  PaddingAll5,
  PaddingAll12,
}
enum ButtonVariant {
  FillBlue700,
  OutlineBlue700,
darkGray16Width500,
  FillWhiteA7000f,
  FillRed50,
  OutlineGray200,
  FillGreen5001,
  OutlineBluegray10002,
  FillBlack90001,
   FillNavy153871,
}
enum ButtonFontStyle {
  InterBold16WhiteA700,
  InterBold16,
  InterMedium16,
  InterMedium16Blue700,
  InterRegular12,
  InterMedium12,
  InterBold20,
  InterRegular12Green500,
  InterSemiBold14,
  InterSemiBold14WhiteA700,
}
