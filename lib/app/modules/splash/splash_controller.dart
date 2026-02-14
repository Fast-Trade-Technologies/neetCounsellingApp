import 'package:get/get.dart';

import '../../core/storage/app_storage.dart';
import '../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(const Duration(milliseconds: 600));
    if (AppStorage.isLoggedIn) {
      Get.offAllNamed(AppRoutes.home);
    } else if (AppStorage.onboardingCompleted) {
      Get.offAllNamed(AppRoutes.login);
    } else {
      Get.offAllNamed(AppRoutes.onboarding);
    }
  }
}
