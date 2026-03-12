import 'package:get/get.dart';

import '../../../api_services/dashboard_api.dart';
import '../../../api_services/filters_api.dart';
import '../../core/models/dashboard_models.dart';

class NewsListController extends GetxController {
  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  final RxString selectedStateId = ''.obs;
  final RxString selectedStateName = ''.obs;

  final RxList<NewsUpdateItem> list = <NewsUpdateItem>[].obs;
  final RxBool loading = false.obs;
  final RxString error = ''.obs;

  @override
  void onReady() {
    super.onReady();
    loadStates();
    loadData();
  }

  Future<void> loadStates() async {
    final (success, states, _) = await FiltersApi.getStates(showLoader: false);
    if (success && states.isNotEmpty) stateFilters.assignAll(states);
  }

  void setStateFilter(FilterItem? item) {
    if (item == null) {
      selectedStateId.value = '';
      selectedStateName.value = '';
    } else {
      selectedStateId.value = item.id;
      selectedStateName.value = item.name;
    }
    loadData();
  }

  Future<void> loadData() async {
    error.value = '';
    loading.value = true;
    list.clear();
    final (success, data, msg) = await DashboardApi.getDashboard(
      showLoader: false,
      newsStateId: selectedStateId.value.isEmpty ? null : selectedStateId.value,
    );
    loading.value = false;
    if (success && data != null && data.newsUpdates != null) {
      list.assignAll(data.newsUpdates!);
    } else {
      error.value = msg ?? 'Failed to load news';
    }
  }
}
