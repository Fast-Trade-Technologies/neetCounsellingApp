import 'package:get/get.dart';

import '../../../api_services/dashboard_api.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;
  final Rxn<Map<String, dynamic>> dashboardData = Rxn<Map<String, dynamic>>();
  final RxBool dashboardLoading = false.obs;
  final RxString dashboardError = ''.obs;

  void setIndex(int index) => currentIndex.value = index;

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    if (args != null && args is int && args >= 0 && args <= 3) {
      currentIndex.value = args;
    }
    loadDashboard();
  }

  Future<void> loadDashboard() async {
    dashboardError.value = '';
    dashboardLoading.value = true;
    dashboardData.value = null;
    final (success, data, errorMessage) = await DashboardApi.getDashboard(showLoader: false);
    dashboardLoading.value = false;
    if (success && data != null) {
      dashboardData.value = data;
    } else {
      dashboardError.value = errorMessage ?? 'Failed to load dashboard';
    }
  }
}
