import 'package:get/get.dart';

import '../modules/post_exam/sycc_report/sycc_report_controller.dart';

class SyccReportBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(SyccReportController());
  }
}
