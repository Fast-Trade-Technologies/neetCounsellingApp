import 'package:get/get.dart';

import '../modules/analysis/courses/courses_controller.dart';

class CoursesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CoursesController());
  }
}
