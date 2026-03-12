import 'package:get/get.dart';

import '../modules/dashboard/important_links_controller.dart';

class ImportantLinksBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ImportantLinksController>(() => ImportantLinksController());
  }
}
