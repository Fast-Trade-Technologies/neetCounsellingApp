import 'package:get/get.dart';

import '../modules/more/about/about_controller.dart';

class AboutBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(AboutController());
  }
}
