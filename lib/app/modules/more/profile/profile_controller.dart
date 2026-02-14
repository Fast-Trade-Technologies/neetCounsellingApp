import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/storage/app_storage.dart';

class ProfileController extends GetxController {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController emailController = TextEditingController();

  final RxString displayName = 'User'.obs;
  final RxString displayPhone = '—'.obs;
  final RxString displayEmail = '—'.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  void _loadFromStorage() {
    final name = AppStorage.userName ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      firstNameController.text = parts.first;
      lastNameController.text = parts.sublist(1).join(' ');
    } else if (parts.length == 1 && parts.first.isNotEmpty) {
      firstNameController.text = parts.first;
    }
    phoneController.text = AppStorage.userPhone?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    emailController.text = AppStorage.userEmail ?? '';
    _updateDisplayValues();
  }

  void _updateDisplayValues() {
    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();
    displayName.value = first.isEmpty && last.isEmpty ? 'User' : [first, last].where((s) => s.isNotEmpty).join(' ');
    final phone = phoneController.text.trim();
    displayPhone.value = phone.isEmpty ? '—' : '+91 $phone';
    final email = emailController.text.trim();
    displayEmail.value = email.isEmpty ? '—' : email;
  }

  Future<void> onSubmit() async {
    final first = firstNameController.text.trim();
    final last = lastNameController.text.trim();
    final phone = phoneController.text.trim().replaceAll(RegExp(r'[^\d]'), '');
    final email = emailController.text.trim();

    if (first.isEmpty) {
      AppSnackbar.warning('Required', 'Enter first name');
      return;
    }
    if (phone.length < 10) {
      AppSnackbar.warning('Invalid', 'Enter valid 10-digit phone number');
      return;
    }

    AppStorage.userName = [first, last].where((s) => s.isNotEmpty).join(' ');
    AppStorage.userPhone = phone;
    AppStorage.userEmail = email.isEmpty ? null : email;
    _updateDisplayValues();
    AppSnackbar.success('Profile Updated', 'Your details have been saved.');
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    phoneController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
