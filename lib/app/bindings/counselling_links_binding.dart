import 'package:get/get.dart';

import '../modules/dashboard/counselling_links_controller.dart';

class CounsellingLinksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CounsellingLinksController>(() => CounsellingLinksController());
  }
}
