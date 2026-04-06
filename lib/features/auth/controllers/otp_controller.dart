import 'dart:async';
import 'package:get/get.dart';
import 'package:local_govt_mw/features/auth/domain/models/otp_model.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:flutter/material.dart';

class OtpController extends GetxController with CodeAutoFill {
  Rx<TextEditingController> otpController = TextEditingController(text: "").obs;
  Rx<OtpModel> otpModelObj = OtpModel().obs;

  // Countdown timer variables
  RxInt remainingSeconds = 300.obs; // 5 minutes = 300 seconds
  Timer? _timer;

  String get formattedTime {
    final minutes = (remainingSeconds.value ~/ 60).toString().padLeft(2, '0');
    final seconds = (remainingSeconds.value % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void startTimer() {
    _timer?.cancel();
    remainingSeconds.value = 300; // reset to 5 minutes
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void codeUpdated() {
    otpController.value.text = code!;
  }

  @override
  void onInit() {
    super.onInit();
    listenForCode();
    startTimer(); // start countdown automatically
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }

  @override
  void dispose() {
    otpController.value.dispose();
    _timer?.cancel();
    super.dispose();
  }
}
