import 'package:get/get.dart';

import '../modules/tools/college_ranking/college_ranking_controller.dart';

class CollegeRankingBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CollegeRankingController());
  }
}
