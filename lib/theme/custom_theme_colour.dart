import 'dart:ui';
import 'package:flutter/material.dart';

class ColorConstant {
  static Color indigoA100 = fromHex('#a39eff');

  static Color gray80001 = fromHex('#373742');

  static Color red400 = fromHex('#f65858');

  static Color whiteA700Ea = fromHex('#eafdfdfd');

  static Color lightBlue900 = fromHex('#202734');
  // static Color lightBlue900 = fromHex('#0060af');

  static Color green500 = fromHex('#45c253');

  static Color greenA700 = fromHex('#0bbc07');

  static Color black90001 = fromHex('#0f0f0f');

  static Color whiteA70014 = fromHex('#14ffffff');

  static Color yellow800 = fromHex('#eaac33');

  static Color lightBlueA700 = fromHex('#007aff');

  static Color gray20001 = fromHex('#ededed');

  static Color whiteA70019 = fromHex('#19ffffff');

  static Color blueGray900 = fromHex('#232a41');

  static Color deepPurpleA200 = fromHex('#756df8');

  static Color gray9000f = fromHex('#0f1d1f29');

  static Color purple300 = fromHex('#af57dd');

  static Color whiteA7004c = fromHex('#4cffffff');

  static Color gray600 = fromHex('#657179');

  static Color gray400 = fromHex('#adadb1');

  static Color blueGray100 = fromHex('#d1d5db');

  static Color orangeA200 = fromHex('#f8aa35');

  static Color blue700 = fromHex('#202734');

  static Color gray800 = fromHex('#404048');

  static Color redA200 = fromHex('#ff6161');

  static Color gray8009901 = fromHex('#993c3c43');

  static Color whiteA7000f = fromHex('#0fffffff');

  static Color gray200 = fromHex('#ebebeb');

  static Color gray80099 = fromHex('#99404048');

  static Color black9000c = fromHex('#0c000000');

  static Color whiteA70063 = fromHex('#63ffffff');

  static Color bluegray400 = fromHex('#888888');

  static Color gray10001 = fromHex('#f4f5f2');

  static Color blue300 = fromHex('#5ec1f7');

  static Color gray8004d = fromHex('#4d3c3c43');

  static Color whiteA700 = fromHex('#ffffff');

  static Color green200 = fromHex('#9cff9a');

  static Color blueGray50 = fromHex('#f1f1f1');

  static Color blueGray10001 = fromHex('#d5d8d0');

  static Color deepOrange40084 = fromHex('#FE7A54');

  static Color blueGray10002 = fromHex('#d6d6d6');

  static Color lightGreen100 = fromHex('#d1f1db');

  static Color indigoA200 = fromHex('#4b7be0');

  static Color red300 = fromHex('#f56f6f');

  static Color gray60014 = fromHex('#14747480');

  static Color blueGray80056 = fromHex('#562d3b51');

  static Color red50 = fromHex('#fdf4ed');

  static Color green400 = fromHex('#69c477');

  static Color whiteA70033 = fromHex('#33ffffff');

  static Color whiteA70075 = fromHex('#75ffffff');

  static Color black900 = fromHex('#000000');

  static Color yellow700 = fromHex('#ffb232');

  static Color purple50 = fromHex('#f8e6f9');

  static Color blueGray400 = fromHex('#878787');

  static Color whiteA700A2 = fromHex('#a2ffffff');

  static Color indigo50 = fromHex('#e6e5ff');

  static Color lightBlue50 = fromHex('#e2f9ff');

  static Color green50 = fromHex('#ebf7eb');

  static Color gray100 = fromHex('#F8F8F8');

  static Color green50001 = fromHex('#49c751');

  static Color whiteA70087 = fromHex('#87ffffff');

  static Color orange50 = fromHex('#fff0d8');

  static Color green5001 = fromHex('#e0ffe3');

  static Color teal5099 = fromHex('#99dce5ee');
  static Color colorF5f5 = fromHex('#F5F5F5');
  static Color colorGreen = fromHex('#46C254');
  static Color colorYelloDeep = fromHex('#EBAD34');
  static Color lightGray = fromHex('#EBECEF');
  static Color dartGray = fromHex('#7A7A7A');
  static Color lightBlack = fromHex('#404148');
  static Color darkBlack = fromHex('#111111');
  static Color darkeshGray = fromHex('#D5D9D1');
  static Color darkGrey = fromHex('#B5B5B5');
  static Color iconButtonBgColor = fromHex('#F8F8F8');

  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write('ff');
    buffer.write(hexString.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
