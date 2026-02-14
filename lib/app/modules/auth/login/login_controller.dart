import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final TextEditingController mobileController = TextEditingController();

  void onGetOtp() {
    // TODO: integrate OTP flow
    Get.offAllNamed(AppRoutes.home);
  }

  void onRegister() => Get.toNamed(AppRoutes.register);

  void onSkip() => Get.offAllNamed(AppRoutes.home);

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}

