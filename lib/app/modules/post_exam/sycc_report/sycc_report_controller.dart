import 'package:get/get.dart';

import '../../../../api_services/sycc_report_api.dart';
import '../../../core/snackbar/app_snackbar.dart';

class SyccReportController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final RxString message = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadSyccReport();
  }

  @override
  Future<void> refresh() async => loadSyccReport(showLoader: false);

  Future<void> loadSyccReport({bool showLoader = true}) async {
    error.value = '';
    isLoading.value = true;
    final (success, data, errorMessage) = await SyccReportApi.getSyccReport(
      showLoader: showLoader,
    );
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load SYCC report';
      AppSnackbar.error('SYCC Report', error.value);
      message.value = '';
      return;
    }
    message.value = data['message']?.toString() ?? '';
  }
}
