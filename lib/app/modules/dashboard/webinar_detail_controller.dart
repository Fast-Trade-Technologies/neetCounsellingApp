import 'package:get/get.dart';
import 'package:neetcounsellingapp/app/core/snackbar/app_snackbar.dart';

import '../../../../api_services/webinar_api.dart';

class WebinarDetailController extends GetxController {
  final RxBool isLoading = false.obs;
  final RxBool isRefreshing = false.obs;
  final RxString error = ''.obs;
  
  final RxString heading = ''.obs;
  final RxString description = ''.obs;
  final RxString imageUrl = ''.obs;
  final RxString dateFormatted = ''.obs;
  final RxString time = ''.obs;
  final RxString location = ''.obs;
  final RxString courseTypeId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    
    // First, load data from passed webinar item (from list page)
    final webinarItemMap = args['webinarItem'] as Map<String, dynamic>?;
    if (webinarItemMap != null) {
      _loadFromWebinarItemMap(webinarItemMap);
    }
    
    // Then fetch fresh data from API in background
    final webinarId = args['webinarId'] as String?;
    if (webinarId != null && webinarId.isNotEmpty) {
      // loadWebinarDetails(webinarId, showLoader: false); // Don't show loader, data already displayed
    } else if (webinarItemMap == null) {
      error.value = 'Webinar data not provided';
    }
  }

  /// Load data from WebinarItem map passed from list page
  void _loadFromWebinarItemMap(Map<String, dynamic> itemMap) {
    heading.value = itemMap['heading']?.toString() ?? itemMap['name']?.toString() ?? '';
    description.value = itemMap['description']?.toString() ?? '';
    imageUrl.value = itemMap['image']?.toString() ?? '';
    dateFormatted.value = itemMap['dateFormatted']?.toString() ?? itemMap['date']?.toString() ?? '';
    time.value = itemMap['time']?.toString() ?? '';
    location.value = itemMap['location']?.toString() ?? '';
    courseTypeId.value = itemMap['courseTypeId']?.toString() ?? '';
  }

  Future<void> loadWebinarDetails(String webinarId, {bool showLoader = true}) async {
    // Only show loading if we don't have data yet
    if (heading.value.isEmpty && description.value.isEmpty) {
      isLoading.value = true;
    } else {
      isRefreshing.value = true; // Show refreshing indicator if we already have data
    }
    error.value = '';

    final (success, data, errorMessage) = await WebinarApi.getWebinarDetails(
      webinarId: webinarId,
      showLoader: showLoader,
    );

    isLoading.value = false;
    isRefreshing.value = false;

    if (success && data != null) {
      // Update with fresh data from API
      heading.value = data['heading']?.toString() ?? heading.value;
      description.value = data['description']?.toString() ?? description.value;
      imageUrl.value = data['image']?.toString() ?? imageUrl.value;
      dateFormatted.value = data['date_formatted']?.toString() ?? data['date']?.toString() ?? dateFormatted.value;
      time.value = data['time']?.toString() ?? time.value;
      location.value = data['location']?.toString() ?? location.value;
      courseTypeId.value = data['course_type_id']?.toString() ?? courseTypeId.value;
    } else {
      // Only show error if we don't have any data to display
      if (heading.value.isEmpty && description.value.isEmpty) {
        error.value = errorMessage ?? 'Failed to load webinar details';
        AppSnackbar.error('Webinar', error.value);
      }
      // If we have data from list, silently fail (data already displayed)
    }
  }

  @override
  Future<void> refresh() async {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final webinarId = args['webinarId'] as String?;
    if (webinarId != null && webinarId.isNotEmpty) {
      await loadWebinarDetails(webinarId, showLoader: false);
    }
  }
}
