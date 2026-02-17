import 'package:get/get.dart';

import '../../../core/storage/app_storage.dart';
import '../../../routes/app_routes.dart';

class MoreMenuController extends GetxController {
  final RxString userName = ''.obs;
  final RxString userEmail = ''.obs;
  final RxString userImageUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadProfileData();
  }

  void _loadProfileData() {
    userName.value = AppStorage.userName?.trim() ?? 'User';
    userEmail.value = AppStorage.userEmail ?? '';
    userImageUrl.value = AppStorage.userImageUrl ?? '';
  }

  @override
  Future<void> refresh() async {
    _loadProfileData();
  }

  Future<void> onLogout() async {
    await AppStorage.clearAll();
    Get.offAllNamed(AppRoutes.login);
  }
}
