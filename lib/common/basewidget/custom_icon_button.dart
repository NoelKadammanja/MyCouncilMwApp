import 'package:flutter/material.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/size_utils.dart';

class CustomIconButton extends StatefulWidget {
  CustomIconButton({
    this.shape,
    this.padding,
    this.variant,
    this.alignment,
    this.margin,
    this.width,
    this.height,
    this.child,
    this.onTap,
  });

  final IconButtonShape? shape;
  final IconButtonPadding? padding;
  final IconButtonVariant? variant;
  final Alignment? alignment;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Widget? child;
  final VoidCallback? onTap;

  @override
  State<CustomIconButton> createState() => _CustomIconButtonState();
}

class _CustomIconButtonState extends State<CustomIconButton> {
  double _scale = 1.0;

  void _onTapDown(TapDownDetails _) {
    setState(() => _scale = 0.95);
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
        ? Align(alignment: widget.alignment ?? Alignment.center, child: _buildIconButtonWidget())
        : _buildIconButtonWidget();
  }

  Widget _buildIconButtonWidget() {
    return Padding(
      padding: widget.margin ?? EdgeInsets.zero,
      child: GestureDetector(
        onTapDown: _onTapDown,
        onTapUp: _onTapUp,
        onTapCancel: _onTapCancel,
        onTap: widget.onTap,
        behavior: HitTestBehavior.translucent,
        child: AnimatedScale(
          scale: _scale,
          duration: const Duration(milliseconds: 120),
          curve: Curves.easeOut,
          child: Material(
            color: Colors.transparent,
            child: Ink(
              width: getSize(widget.width ?? 0),
              height: getSize(widget.height ?? 0),
              decoration: _buildDecoration(),
              child: InkWell(
                borderRadius: _setBorderRadius(),
                onTap: widget.onTap,
                child: Container(
                  alignment: Alignment.center,
                  padding: _setPadding(),
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _buildDecoration() {
    return BoxDecoration(
      shape: BoxShape.circle,
      color: _setColor(),
      border: _setBorder(),
      // borderRadius: _setBorderRadius(),
      gradient: _setGradient(),
      boxShadow: _setBoxShadow(),
    );
  }

  _setPadding() {
    switch (widget.padding) {
      case IconButtonPadding.PaddingAll10:
        return getPadding(
          all: 10,
        );
      case IconButtonPadding.PaddingAll16:
        return getPadding(
          all: 16,
        );
      case IconButtonPadding.PaddingAll22:
        return getPadding(
          all: 22,
        );
      case IconButtonPadding.PaddingAll1:
        return getPadding(
          all: 1,
        );
      case IconButtonPadding.PaddingAll5:
        return getPadding(
          all: 5,
        );
      default:
        return getPadding(
          all: 13,
        );
    }
  }

  _setColor() {
    switch (widget.variant) {
      case IconButtonVariant.FillWhiteA70014:
        return ColorConstant.whiteA70014
        ;case IconButtonVariant.lightGrayBgIconButton:
        return ColorConstant.lightGray;
      case IconButtonVariant.FillWhiteA700:
        return ColorConstant.whiteA700;
      case IconButtonVariant.FillBlue700:
        return ColorConstant.blue700;
      case IconButtonVariant.OutlineGray200:
        return ColorConstant.whiteA700;
      case IconButtonVariant.FillLightblue900:
        return ColorConstant.lightBlack;
      case IconButtonVariant.OutlineDeeporange40084:
        return ColorConstant.blue700;
      case IconButtonVariant.FillIndigoA200:
        return ColorConstant.indigoA200;
      case IconButtonVariant.FillPurple300:
        return ColorConstant.purple300;
      case IconButtonVariant.FillGreen50001:
        return ColorConstant.green50001;
      case IconButtonVariant.FillGray10001:
        return ColorConstant.gray10001;
      case IconButtonVariant.OutlineBlack9000c:
        return ColorConstant.whiteA700;
      case IconButtonVariant.FillGray60014:
        return ColorConstant.gray60014;
      case IconButtonVariant.OutlineGray20001://OutlineGray200
        return ColorConstant.whiteA700;
      case IconButtonVariant.OutlineWhiteA7004c:
        return null;
      default:
        return ColorConstant.gray100;
    }
  }

  _setBorder() {
    switch (widget.variant) {
      case IconButtonVariant.OutlineGray200:
        return Border.all(
          color: ColorConstant.gray200,
          width: getHorizontalSize(
            1.00,
          ),
        );
      case IconButtonVariant.OutlineWhiteA7004c:
        return Border.all(
          color: ColorConstant.whiteA7004c,
          width: getHorizontalSize(
            1.00,
          ),
        );
      case IconButtonVariant.OutlineGray20001:
        return Border.all(
          color: ColorConstant.gray20001,
          width: getHorizontalSize(
            1.00,
          ),
        );
      case IconButtonVariant.FillWhiteA70014:
      case IconButtonVariant.lightGrayBgIconButton:
      case IconButtonVariant.FillWhiteA700:
      case IconButtonVariant.FillBlue700:
      case IconButtonVariant.FillLightblue900:
      case IconButtonVariant.FillGray100:
      case IconButtonVariant.OutlineDeeporange40084:
      case IconButtonVariant.FillIndigoA200:
      case IconButtonVariant.FillPurple300:
      case IconButtonVariant.FillGreen50001:
      case IconButtonVariant.FillGray10001:
      case IconButtonVariant.OutlineBlack9000c:
      case IconButtonVariant.FillGray60014:
        return null;
      default:
        return null;
    }
  }

  _setBorderRadius() {
    switch (widget.shape) {
      case IconButtonShape.CircleBorder22:
        return BorderRadius.circular(
          getHorizontalSize(
            22.00,
          ),
        );
      case IconButtonShape.CircleBorder32:
        return BorderRadius.circular(
          getHorizontalSize(
            32.00,
          ),
        );
        case IconButtonShape.CircleBorder8:
        return BorderRadius.circular(
          getHorizontalSize(
            8.00,
          ),
        );
      case IconButtonShape.CircleBorder28:
        return BorderRadius.circular(
          getHorizontalSize(
            28.00,
          ),
        );
      case IconButtonShape.RoundedBorder12:
        return BorderRadius.circular(
          getHorizontalSize(
            8.00,
          ),
        );
      case IconButtonShape.CircleBorder18:
        return BorderRadius.circular(
          getHorizontalSize(
            18.00,
          ),
        );
      case IconButtonShape.RoundedBorder1:
        return BorderRadius.circular(
          getHorizontalSize(
            1.00,
          ),
        );
      case IconButtonShape.CircleBorder15:
        return BorderRadius.circular(
          getHorizontalSize(
            15.00,
          ),
        );
      case IconButtonShape.RoundedBorder8:
        return BorderRadius.circular(
          getHorizontalSize(
            8.00,
          ),
        );
      default:
        return BorderRadius.circular(
          getHorizontalSize(
            25.00,
          ),
        );
    }
  }

  _setGradient() {
    switch (widget.variant) {
      case IconButtonVariant.OutlineWhiteA7004c:
        return LinearGradient(
          begin: Alignment(
            0.88,
            0.04,
          ),
          end: Alignment(
            0.19,
            1,
          ),
          colors: [
            ColorConstant.lightBlack,
            ColorConstant.lightBlack,
          ],
        );
      case IconButtonVariant.FillWhiteA70014:
      case IconButtonVariant.lightGrayBgIconButton:
      case IconButtonVariant.FillWhiteA700:
      case IconButtonVariant.FillBlue700:
      case IconButtonVariant.OutlineGray200:
      case IconButtonVariant.FillLightblue900:
      case IconButtonVariant.FillGray100:
      case IconButtonVariant.OutlineDeeporange40084:
      case IconButtonVariant.FillIndigoA200:
      case IconButtonVariant.FillPurple300:
      case IconButtonVariant.FillGreen50001:
      case IconButtonVariant.FillGray10001:
      case IconButtonVariant.OutlineBlack9000c:
      case IconButtonVariant.FillGray60014:
      case IconButtonVariant.OutlineGray20001:
        return null;
      default:
        return null;
    }
  }

  _setBoxShadow() {
    switch (widget.variant) {
      case IconButtonVariant.OutlineDeeporange40084:
        return [
          BoxShadow(
            color: ColorConstant.blue700.withOpacity(0.52),
            spreadRadius: getHorizontalSize(
             -8,
            ),
            blurRadius: getHorizontalSize(
              24.00,
            ),
            offset: Offset(
              0,
              16,
            ),
          )
        ];
      case IconButtonVariant.OutlineBlack9000c:
        return [
          BoxShadow(
            color: ColorConstant.black9000c,
            spreadRadius: getHorizontalSize(
              2.00,
            ),
            blurRadius: getHorizontalSize(
              2.00,
            ),
            offset: Offset(
              0,
              0,
            ),
          )
        ];
      case IconButtonVariant.FillWhiteA70014:
      case IconButtonVariant.lightGrayBgIconButton:
      case IconButtonVariant.FillWhiteA700:
      case IconButtonVariant.FillBlue700:
      case IconButtonVariant.OutlineGray200:
      case IconButtonVariant.FillLightblue900:
      case IconButtonVariant.OutlineWhiteA7004c:
      case IconButtonVariant.FillGray100:
      case IconButtonVariant.FillIndigoA200:
      case IconButtonVariant.FillPurple300:
      case IconButtonVariant.FillGreen50001:
      case IconButtonVariant.FillGray10001:
      case IconButtonVariant.FillGray60014:
      case IconButtonVariant.OutlineGray20001:
        return null;
      default:
        return null;
    }
  }
}

enum IconButtonShape {
  CircleBorder25,
  CircleBorder22,
  CircleBorder32,
  CircleBorder8,
  CircleBorder28,
  RoundedBorder12,
  CircleBorder18,
  RoundedBorder1,
  CircleBorder15,
  RoundedBorder8,
}
enum IconButtonPadding {
  PaddingAll13,
  PaddingAll10,
  PaddingAll16,
  PaddingAll22,
  PaddingAll1,
  PaddingAll5,
}
enum IconButtonVariant {
  FillWhiteA70014,
  lightGrayBgIconButton,
  FillWhiteA700,
  FillBlue700,
  OutlineGray200,
  FillLightblue900,
  OutlineWhiteA7004c,
  FillGray100,
  OutlineDeeporange40084,
  FillIndigoA200,
  FillPurple300,
  FillGreen50001,
  FillGray10001,
  OutlineBlack9000c,
  FillGray60014,
  OutlineGray20001,
}
//lightGray