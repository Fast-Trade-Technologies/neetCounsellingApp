import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api_services/auth_api.dart';
import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/storage/app_storage.dart';
import '../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final TextEditingController mobileController = TextEditingController();
  final RxBool isLoading = false.obs;

  @override
  void onReady() {
    super.onReady();
    if (AppStorage.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  Future<void> onGetOtp() async {
    final phone = mobileController.text.trim();
    if (phone.isEmpty) {
      AppSnackbar.warning('Required', 'Enter mobile number');
      return;
    }
    if (phone.length < 10) {
      AppSnackbar.error('Invalid', 'Enter valid 10-digit mobile number');
      return;
    }

    isLoading.value = true;
    final (success, errorMessage) = await AuthApi.login(
      mobile: phone,
      otpType: 'whatsapp',
      showLoader: true,
    );
    isLoading.value = false;

    if (success) {
      AppStorage.userPhone = phone;
      AppSnackbar.success('OTP Sent', 'Verification code sent to $phone');
      Get.toNamed(AppRoutes.otp, arguments: phone);
    } else {
      AppSnackbar.error('Login', errorMessage ?? 'Failed to send OTP');
    }
  }

  void onRegister() => Get.toNamed(AppRoutes.register);

  void onSkip() => Get.offAllNamed(AppRoutes.home);

  @override
  void onClose() {
    mobileController.dispose();
    super.onClose();
  }
}

