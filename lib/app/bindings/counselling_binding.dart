import 'package:get/get.dart';

import '../modules/tools/counselling/counselling_controller.dart';

class CounsellingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CounsellingController());
  }
}
