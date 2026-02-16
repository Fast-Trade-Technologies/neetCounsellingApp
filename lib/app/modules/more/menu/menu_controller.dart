import 'package:get/get.dart';

import '../../../core/storage/app_storage.dart';
import '../../../routes/app_routes.dart';

class MoreMenuController extends GetxController {
  Future<void> refresh() async {}

  Future<void> onLogout() async {
    await AppStorage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
