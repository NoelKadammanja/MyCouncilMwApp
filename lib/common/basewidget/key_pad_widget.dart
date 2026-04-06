import 'package:flutter/material.dart';
import 'package:local_govt_mw/common/basewidget/custom_image_view.dart';
import 'package:local_govt_mw/theme/custom_theme_colour.dart';
import 'package:local_govt_mw/utill/images.dart';
import 'package:local_govt_mw/utill/size_utils.dart';


class KeyPad extends StatelessWidget{
  double buttonSize = 60.0;
  final TextEditingController pinController;
  final Function onChange;
  final Function onSubmit;
  final bool isPinLogin;
  KeyPad({required this.onChange, required this.onSubmit, required this.pinController, required this.isPinLogin});
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 24, right: 24),
      child: Column(
        children: [
          SizedBox(height: getVerticalSize(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonWidget('1'),
              buttonWidget('2'),
              buttonWidget('3'),
            ],
          ),
          SizedBox(height: getVerticalSize(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonWidget('4'),
              buttonWidget('5'),
              buttonWidget('6'),
            ],
          ),
          SizedBox(height: getVerticalSize(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              buttonWidget('7'),
              buttonWidget('8'),
              buttonWidget('9'),
            ],
          ),
          SizedBox(height: getVerticalSize(20)),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              iconButtonWidget( Text(".",style: TextStyle(
                color: ColorConstant.gray800,
                fontSize: getFontSize(
                  20,
                ),
                fontFamily: 'Inter',
                fontWeight: FontWeight.w700,
              ),),() {
                if (pinController.text.length > 0) {
                  pinController.text = pinController.text
                      .substring(0, pinController.text.length - 1);
                }
                if (pinController.text.length > 5) {
                  pinController.text = pinController.text.substring(0, 3);
                }
                onChange(pinController.text);
              }),
              buttonWidget('0',),
              !isPinLogin
                  ? iconButtonWidget(CustomImageView(
                                    svgPath: ImageConstant
                                        .imgBackspace), () {
                if (pinController.text.length > 5) {
                  pinController.text = pinController.text.substring(0, 3);
                }
                onSubmit(pinController.text);
              })
                  : Container(
                width: buttonSize,
              ),
            ],
          ),
        ],
      ),
    );
  }
  buttonWidget(String buttonText) {
    return GestureDetector(
      onTap: (){
        if (pinController.text.length <= 3) {
          pinController.text = pinController.text + buttonText;
          onChange(pinController.text);
        }
      },
      child: Container(
        height: buttonSize,
        width: buttonSize,
        decoration: BoxDecoration(
        border: Border.all(color: ColorConstant.gray200),
          shape: BoxShape.circle,

        ),

        child: Center(
          child: Text(
            buttonText,
            style: TextStyle(
              color: ColorConstant.gray800,
              fontSize: getFontSize(
                20,
              ),
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

      ),
    );
  }
  iconButtonWidget(widget, Function function) {
    return InkWell(
      onTap: function(),
      child: Container(
        height: buttonSize,
        width: buttonSize,
        decoration: BoxDecoration(
          border: Border.all(color: ColorConstant.gray200),
          shape: BoxShape.circle,

        ),
        child: Center(
          child:  widget
        ),
      ),
    );
  }
}