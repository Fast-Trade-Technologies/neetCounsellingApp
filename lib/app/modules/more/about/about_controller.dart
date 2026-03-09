import 'package:get/get.dart';

import '../../../../api_services/about_api.dart';
import '../../../core/models/about_models.dart';

class AboutController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;
  final Rxn<AboutData> aboutData = Rxn<AboutData>();

  @override
  void onInit() {
    super.onInit();
    loadAbout();
  }

  Future<void> loadAbout({bool showLoader = true}) async {
    isLoading.value = true;
    error.value = '';

    final (success, data, errorMessage) = await AboutApi.getAbout(showLoader: showLoader);

    isLoading.value = false;

    if (success && data != null) {
      try {
        aboutData.value = AboutData.fromJson(data);
      } catch (e) {
        error.value = 'Failed to parse about data: ${e.toString()}';
      }
    } else {
      error.value = errorMessage ?? 'Failed to load about page';
    }
  }

  @override
  Future<void> refresh() async {
    await loadAbout(showLoader: false);
  }
}
