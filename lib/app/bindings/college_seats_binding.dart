import 'package:get/get.dart';

import '../modules/analysis/college_seats/college_seats_controller.dart';

class CollegeSeatsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CollegeSeatsController());
  }
}
