import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api_services/auth_api.dart';
import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/storage/app_storage.dart';
import '../../../routes/app_routes.dart';

class OtpController extends GetxController {
  static const int otpLength = 4;
  final List<TextEditingController> pinControllers = List.generate(otpLength, (_) => TextEditingController());
  final List<FocusNode> focusNodes = List.generate(otpLength, (_) => FocusNode());
  final RxString phone = ''.obs;
  final RxBool isLoading = false.obs;
  final RxInt resendSeconds = 0.obs;
  Timer? _resendTimer;

  String get pinText => pinControllers.map((c) => c.text).join();

  @override
  void onReady() {
    super.onReady();
    if (focusNodes.isNotEmpty) {
      FocusScope.of(Get.context!).requestFocus(focusNodes.first);
    }
  }

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null && args is String) phone.value = args;
    startResendTimer();
  }

  @override
  void onClose() {
    _resendTimer?.cancel();
    for (final c in pinControllers) c.dispose();
    for (final f in focusNodes) f.dispose();
    super.onClose();
  }

  void onOtpDigitChanged(int index, String value) {
    if (value.length == 1) {
      if (index < otpLength - 1) FocusScope.of(Get.context!).requestFocus(focusNodes[index + 1]);
    }
  }

  void onOtpKeyBackspace(int index) {
    if (pinControllers[index].text.isEmpty && index > 0) {
      pinControllers[index - 1].clear();
      FocusScope.of(Get.context!).requestFocus(focusNodes[index - 1]);
    }
  }

  void startResendTimer() {
    resendSeconds.value = 60;
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (resendSeconds.value > 0) {
        resendSeconds.value--;
      } else {
        t.cancel();
      }
    });
  }

  String? validateOtp(String? value) {
    if (value == null || value.trim().isEmpty) return 'Enter OTP';
    if (value.trim().length != otpLength) return 'Enter $otpLength digit OTP';
    return null;
  }

  Future<void> onSubmit() async {
    final otp = pinText.trim();
    final err = validateOtp(otp);
    if (err != null) {
      AppSnackbar.error('Invalid OTP', err);
      return;
    }
    final token = AppStorage.loginToken;
    if (token == null || token.isEmpty) {
      AppSnackbar.error('Session expired', 'Please request OTP again from login.');
      return;
    }
    isLoading.value = true;
    final (success, errorMessage, userId) = await AuthApi.verifyOtp(
      otp: otp,
      token: token,
      showLoader: true,
    );
    isLoading.value = false;
    if (success && userId != null) {
      AppStorage.userId = userId;
      AppStorage.isLoggedIn = true;
      AppStorage.userPhone = phone.value.isNotEmpty ? phone.value : null;
      Get.offAllNamed(AppRoutes.home);
    } else {
      AppSnackbar.error('Verification failed', errorMessage ?? 'Invalid OTP');
    }
  }

  Future<void> onResendOtp() async {
    if (resendSeconds.value > 0) return;
    final token = AppStorage.loginToken;
    if (token == null || token.isEmpty) {
      AppSnackbar.warning('Session expired', 'Please go back and request OTP again.');
      return;
    }
    final (success, errorMessage) = await AuthApi.resendOtp(token: token, showLoader: false);
    if (success) {
      startResendTimer();
      AppSnackbar.success('OTP Sent', 'New OTP sent to ${phone.value}');
    } else {
      AppSnackbar.error('Resend failed', errorMessage ?? 'Could not resend OTP');
    }
  }
}
