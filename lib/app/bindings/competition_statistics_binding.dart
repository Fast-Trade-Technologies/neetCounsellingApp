import 'package:get/get.dart';

import '../modules/analysis/competition_statistics/competition_statistics_controller.dart';

class CompetitionStatisticsBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(CompetitionStatisticsController());
  }
}
