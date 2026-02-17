import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api_services/auth_api.dart';
import '../../../../api_services/profile_api.dart';
import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/storage/app_storage.dart';
import '../../../routes/app_routes.dart';

class OtpController extends GetxController {
  static const int otpLength = 4;
  final TextEditingController pinputController = TextEditingController();
  final FocusNode pinputFocusNode = FocusNode();
  final RxString phone = ''.obs;
  final RxBool isLoading = false.obs;
  final RxInt resendSeconds = 0.obs;
  Timer? _resendTimer;

  String get pinText => pinputController.text.trim();

  @override
  void onReady() {
    super.onReady();
    // Auto-focus the Pinput field when page loads
    Future.delayed(const Duration(milliseconds: 300), () {
      pinputFocusNode.requestFocus();
    });
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
    pinputController.dispose();
    pinputFocusNode.dispose();
    super.onClose();
  }

  void onOtpChanged(String value) {
    // Optional: Handle OTP change if needed
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
    final otp = pinText;
    final err = validateOtp(otp);
    if (err != null) {
      AppSnackbar.error('Invalid OTP', err);
      pinputFocusNode.requestFocus();
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
      
      // Fetch and save profile data after successful OTP verification
      await _fetchAndSaveProfile();
      
      Get.offAllNamed(AppRoutes.home);
    } else {
      AppSnackbar.error('Verification failed', errorMessage ?? 'Invalid OTP');
    }
  }

  /// Fetch profile data from API and save to local storage
  Future<void> _fetchAndSaveProfile() async {
    try {
      final (success, data, errorMessage) = await ProfileApi.getProfile(showLoader: false);
      
      if (success && data != null) {
        // Parse API response and save ALL fields to storage
        final id = data['id']?.toString();
        final firstName = (data['first_name']?.toString() ?? data['firstName']?.toString() ?? '').trim();
        final lastName = (data['last_name']?.toString() ?? data['lastName']?.toString() ?? '').trim();
        final mobile = (data['mobile']?.toString() ?? data['phone']?.toString() ?? '').trim();
        final email = (data['email']?.toString() ?? '').trim();
        final stream = data['stream']?.toString();
        final paidStatus = data['paid_status']?.toString();
        final image = data['image']?.toString();
        final streamName = data['stream_name']?.toString();
        final imageUrl = data['image_url']?.toString();

        // Save ALL fields to local storage
        if (id != null && id.isNotEmpty) AppStorage.userId = id;
        AppStorage.userFirstName = firstName.isEmpty ? null : firstName;
        AppStorage.userLastName = lastName.isEmpty ? null : lastName;
        if (mobile.isNotEmpty) {
          AppStorage.userPhone = mobile.replaceAll(RegExp(r'[^\d]'), '');
        }
        AppStorage.userEmail = email.isEmpty ? null : email;
        if (firstName.isNotEmpty || lastName.isNotEmpty) {
          AppStorage.userName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
        }
        if (stream != null && stream.isNotEmpty) AppStorage.userStream = stream;
        if (paidStatus != null && paidStatus.isNotEmpty) AppStorage.userPaidStatus = paidStatus;
        if (image != null && image.isNotEmpty) AppStorage.userImage = image;
        if (streamName != null && streamName.isNotEmpty) AppStorage.userStreamName = streamName;
        if (imageUrl != null && imageUrl.isNotEmpty) AppStorage.userImageUrl = imageUrl;
      } else {
        // Profile fetch failed, but continue with login
        // User can update profile later from profile page
        if (errorMessage != null && errorMessage.isNotEmpty) {
          // Silently fail - don't show error as login was successful
          // Profile can be loaded later from profile page
        }
      }
    } catch (e) {
      // Silently fail - don't show error as login was successful
      // Profile can be loaded later from profile page
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
      // Clear the OTP field when resending
      pinputController.clear();
      pinputFocusNode.requestFocus();
      startResendTimer();
      AppSnackbar.success('OTP Sent', 'New OTP sent to ${phone.value}');
    } else {
      AppSnackbar.error('Resend failed', errorMessage ?? 'Could not resend OTP');
    }
  }
}
