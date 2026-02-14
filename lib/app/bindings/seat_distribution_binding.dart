import 'package:get/get.dart';

import '../modules/analysis/seat_distribution/seat_distribution_controller.dart';

class SeatDistributionBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SeatDistributionController());
  }
}
