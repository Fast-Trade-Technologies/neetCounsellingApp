import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/storage/app_storage.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final TextEditingController mobileController = TextEditingController();

  @override
  void onReady() {
    super.onReady();
    if (AppStorage.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void onGetOtp() {
    final phone = mobileController.text.trim();
    if (phone.isEmpty) {
      AppSnackbar.warning('Required', 'Enter mobile number');
      return;
    }
    if (phone.length < 10) {
      AppSnackbar.error('Invalid', 'Enter valid 10-digit mobile number');
      return;
    }
    AppStorage.userPhone = phone;
    Get.toNamed(AppRoutes.otp, arguments: phone);
  }

  void onRegister() => Get.toNamed(AppRoutes.register);

  void onSkip() => Get.offAllNamed(AppRoutes.home);

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}

