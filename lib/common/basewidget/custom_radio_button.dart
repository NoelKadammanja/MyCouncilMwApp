import 'package:flutter/material.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/size_utils.dart';

class CustomRadioButton extends StatelessWidget {
  CustomRadioButton(
      {this.padding,
      this.fontStyle,
      this.margin,
      this.onChange,
      this.iconSize,
      this.value,
      this.groupValue,
      this.text});

  RadioPadding? padding;

  RadioFontStyle? fontStyle;

  EdgeInsetsGeometry? margin;

  Function(String)? onChange;

  double? iconSize;

  String? value;

  String? groupValue;

  String? text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          onChange!(value!);
        },
        child: Container(
        height: 72,
        width: getHorizontalSize(width),
        decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        color: ColorConstant.lightGray,
        ),
          child: IntrinsicWidth(

            child: Center(
              child: ListTile(

                contentPadding: EdgeInsets.zero,
                minLeadingWidth: getHorizontalSize(iconSize ?? 0),
                horizontalTitleGap: getHorizontalSize(
                  10,
                ),
                leading: Radio<String>(
fillColor: MaterialStateColor.resolveWith((states) => ColorConstant.darkBlack),
                  value: value ?? "",
                  activeColor: ColorConstant.darkBlack,

                  groupValue: groupValue,
                  onChanged: (value) {
                    onChange!(value!);
                  },
                ),

                title: Text(
                  text ?? "",
                  style: _setFontStyle(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  _setFontStyle() {
    switch (fontStyle) {
      default:
        return TextStyle(
          color: ColorConstant.dartGray,
          fontSize: getFontSize(
            16,
          ),
          fontFamily: 'Inter',
          fontWeight: FontWeight.w500,
        );

    }
  }
}

enum RadioPadding {
  PaddingT25,
  paddingAll0
}
enum RadioFontStyle {
  InterMedium16,
}
