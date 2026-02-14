import 'package:get/get.dart';

import '../modules/onboarding/onboarding_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Per request: don't use Get.lazyPut for initial controller.
    Get.put(OnboardingController());
  }
}

