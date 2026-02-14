import 'package:get/get.dart';

import '../modules/auth/register/register_controller.dart';

class RegisterBinding extends Bindings {
  @override
  void dependencies() {
    // Per request: don't use Get.lazyPut.
    Get.put(RegisterController());
  }
}

