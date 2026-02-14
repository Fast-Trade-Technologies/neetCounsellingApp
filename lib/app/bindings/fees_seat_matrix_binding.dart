import 'package:get/get.dart';

import '../modules/tools/fees_seat_matrix/fees_seat_matrix_controller.dart';

class FeesSeatMatrixBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(FeesSeatMatrixController());
  }
}
