import 'package:get/get.dart';

import '../modules/tools/universities_institutes/universities_institutes_controller.dart';

class UniversitiesInstitutesBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(UniversitiesInstitutesController());
  }
}
