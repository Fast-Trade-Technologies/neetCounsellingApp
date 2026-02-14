import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/storage/app_storage.dart';
import '../../routes/app_routes.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();
  final RxInt pageIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    AppStorage.onboardingCompleted = true;
  }

  void onPageChanged(int index) => pageIndex.value = index;

  void goNextOrFinish() {
    if (pageIndex.value >= 3) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}

