import 'package:get/get.dart';

import '../modules/analysis/merit_list/merit_list_controller.dart';

class MeritListBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(MeritListController());
  }
}
