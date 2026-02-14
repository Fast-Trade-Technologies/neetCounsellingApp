import 'package:get/get.dart';

import '../modules/auth/otp/otp_controller.dart';

class OtpBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(OtpController());
  }
}
