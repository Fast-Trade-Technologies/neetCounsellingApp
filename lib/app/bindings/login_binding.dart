import 'package:get/get.dart';

import '../modules/auth/login/login_controller.dart';

class LoginBinding extends Bindings {
  @override
  void dependencies() {
    // Per request: don't use Get.lazyPut.
    Get.put(LoginController());
  }
}

