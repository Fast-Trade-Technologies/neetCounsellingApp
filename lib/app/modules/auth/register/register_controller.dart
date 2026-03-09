import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api_services/auth_api.dart';
import '../../../core/snackbar/app_snackbar.dart';
import '../../../routes/app_routes.dart';

class RegisterController extends GetxController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController mobileController = TextEditingController();
  final RxBool isLoading = false.obs;
  /// API stream mapping: UG -> 0, PG -> 1.
  final RxString selectedStream = '0'.obs;

  Future<void> onSignUp() async {
    final firstName = firstNameController.text.trim();
    final lastName = lastNameController.text.trim();
    final email = emailController.text.trim();
    final mobile = mobileController.text.trim();

    if (firstName.isEmpty) {
      AppSnackbar.warning('Required', 'Enter first name');
      return;
    }
    if (lastName.isEmpty) {
      AppSnackbar.warning('Required', 'Enter last name');
      return;
    }
    if (email.isEmpty) {
      AppSnackbar.warning('Required', 'Enter email');
      return;
    }
    if (mobile.isEmpty) {
      AppSnackbar.warning('Required', 'Enter mobile number');
      return;
    }
    if (mobile.length < 10) {
      AppSnackbar.error('Invalid', 'Enter valid 10-digit mobile number');
      return;
    }

    isLoading.value = true;
    final (success, errorMessage) = await AuthApi.register(
      firstName: firstName,
      lastName: lastName,
      email: email,
      mobile: mobile,
      stream: selectedStream.value,
      showLoader: true,
    );

    if (success) {
      AppSnackbar.success('Registered', 'You can now sign in with your mobile number.');
      Get.offAllNamed(AppRoutes.login);
      return;
    }
    isLoading.value = false;
    AppSnackbar.error('Registration failed', errorMessage ?? 'Please try again.');
  }

  void onSignIn() => Get.offAllNamed(AppRoutes.login);

  void setStream(String streamValue) {
    selectedStream.value = streamValue;
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    mobileController.dispose();
    super.onClose();
  }
}

