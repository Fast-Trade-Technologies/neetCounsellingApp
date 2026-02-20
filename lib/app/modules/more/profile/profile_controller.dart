import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../api_services/profile_api.dart';
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
  final RxString imageUrl = ''.obs;
  /// Local path of picked image (from gallery/camera). Cleared after successful upload.
  final RxString pickedImagePath = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool isUpdating = false.obs;
  final RxString error = ''.obs;

  static final ImagePicker _imagePicker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
    loadProfile();
  }

  @override
  Future<void> refresh() async {
    await loadProfile(showLoader: false);
  }

  /// Load profile from API (GET /user/profile) and save all fields to local storage.
  Future<void> loadProfile({bool showLoader = true}) async {
    error.value = '';
    isLoading.value = true;
    final (success, data, errorMessage) = await ProfileApi.getProfile(showLoader: showLoader);
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load profile';
      // Fallback to storage if API fails
      _loadFromStorage();
      return;
    }

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

    // Update text controllers
    firstNameController.text = firstName;
    lastNameController.text = lastName;
    phoneController.text = mobile.replaceAll(RegExp(r'[^\d]'), '');
    emailController.text = email;

    // Save ALL fields to local storage
    if (id != null && id.isNotEmpty) AppStorage.userId = id;
    AppStorage.userFirstName = firstName.isEmpty ? null : firstName;
    AppStorage.userLastName = lastName.isEmpty ? null : lastName;
    AppStorage.userPhone = mobile.isEmpty ? null : mobile.replaceAll(RegExp(r'[^\d]'), '');
    AppStorage.userEmail = email.isEmpty ? null : email;
    if (firstName.isNotEmpty || lastName.isNotEmpty) {
      AppStorage.userName = [firstName, lastName].where((s) => s.isNotEmpty).join(' ');
    }
    if (stream != null && stream.isNotEmpty) AppStorage.userStream = stream;
    if (paidStatus != null && paidStatus.isNotEmpty) AppStorage.userPaidStatus = paidStatus;
    if (image != null && image.isNotEmpty) AppStorage.userImage = image;
    if (streamName != null && streamName.isNotEmpty) AppStorage.userStreamName = streamName;
    if (imageUrl != null && imageUrl.isNotEmpty) {
      AppStorage.userImageUrl = imageUrl;
      this.imageUrl.value = imageUrl;
    } else {
      this.imageUrl.value = '';
    }

    _updateDisplayValues();
  }

  void _loadFromStorage() {
    final name = AppStorage.userName ?? '';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      firstNameController.text = parts.first;
      lastNameController.text = parts.sublist(1).join(' ');
    } else if (parts.length == 1 && parts.first.isNotEmpty) {
      firstNameController.text = parts.first;
    } else {
      // Try first_name and last_name from storage
      firstNameController.text = AppStorage.userFirstName ?? '';
      lastNameController.text = AppStorage.userLastName ?? '';
    }
    phoneController.text = AppStorage.userPhone?.replaceAll(RegExp(r'[^\d]'), '') ?? '';
    emailController.text = AppStorage.userEmail ?? '';
    imageUrl.value = AppStorage.userImageUrl ?? '';
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

  /// Show source choice and pick image from gallery or camera.
  Future<void> pickImage() async {
    final source = await Get.dialog<ImageSource>(
      AlertDialog(
        title: const Text('Change profile photo'),
        content: const Text('Choose source'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: ImageSource.gallery),
            child: const Text('Gallery'),
          ),
          TextButton(
            onPressed: () => Get.back(result: ImageSource.camera),
            child: const Text('Camera'),
          ),
          TextButton(
            onPressed: () => Get.back(result: null),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
    if (source == null) return;
    final XFile? file = await _imagePicker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (file != null && file.path.isNotEmpty) {
      pickedImagePath.value = file.path;
    }
  }

  /// Update profile via API (PUT /user/profile). Sends first_name, last_name, mobile, email, image_base64 (when new image picked).
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

    String? imageBase64;
    final pickedPath = pickedImagePath.value.trim();
    if (pickedPath.isNotEmpty) {
      final file = File(pickedPath);
      if (file.existsSync()) {
        final bytes = file.readAsBytesSync();
        final base64Str = base64Encode(bytes);
        final ext = pickedPath.toLowerCase();
        final mime = ext.endsWith('.png')
            ? 'image/png'
            : ext.endsWith('.gif')
                ? 'image/gif'
                : 'image/jpeg';
        imageBase64 = 'data:$mime;base64,$base64Str';
      }
    }

    isUpdating.value = true;
    error.value = '';
    final (success, data, errorMessage) = await ProfileApi.updateProfile(
      firstName: first,
      lastName: last,
      mobile: phone,
      email: email.isEmpty ? null : email,
      imageBase64: imageBase64,
      showLoader: true,
    );
    isUpdating.value = false;

    if (!success) {
      error.value = errorMessage ?? 'Failed to update profile';
      AppSnackbar.error('Update Failed', error.value);
      return;
    }

    pickedImagePath.value = '';
    await loadProfile(showLoader: false);
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
