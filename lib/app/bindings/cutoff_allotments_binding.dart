import 'package:get/get.dart';

import '../modules/tools/cutoff_allotments/cutoff_allotments_controller.dart';

class CutoffAllotmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CutoffAllotmentsController());
  }
}
