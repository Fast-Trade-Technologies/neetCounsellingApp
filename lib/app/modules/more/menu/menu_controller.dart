import 'package:get/get.dart';

import '../../../routes/app_routes.dart';

class MoreMenuController extends GetxController {
  void onLogout() {
    Get.offAllNamed(AppRoutes.login);
  }
}
