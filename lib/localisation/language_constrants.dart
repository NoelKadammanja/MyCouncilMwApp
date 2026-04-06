import 'package:flutter/material.dart';
import 'package:local_govt_mw/localisation/app_localisation.dart';

String? getTranslated(String? key, BuildContext context) {
  String? text = key;
  try{
    text = AppLocalization.of(context)!.translate(key);
  }catch (error){
    text = "$key";
  }
  return text;
}