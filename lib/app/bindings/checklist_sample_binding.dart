import 'package:get/get.dart';

import '../modules/post_exam/checklist_sample/checklist_sample_controller.dart';

class ChecklistSampleBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(ChecklistSampleController());
  }
}
