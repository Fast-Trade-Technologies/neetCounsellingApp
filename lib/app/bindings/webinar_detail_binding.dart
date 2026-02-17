import 'package:get/get.dart';

import '../modules/dashboard/webinar_detail_controller.dart';

class WebinarDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(WebinarDetailController());
  }
}
