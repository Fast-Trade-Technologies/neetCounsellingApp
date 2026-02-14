import 'package:get/get.dart';

import '../modules/more/menu/menu_controller.dart';

class MenuBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MoreMenuController());
  }
}
