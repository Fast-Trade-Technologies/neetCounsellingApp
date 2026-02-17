import 'package:get/get.dart';

import '../../../../api_services/filters_api.dart';
import '../../../../api_services/merit_list_api.dart';
import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/utils/url_launcher_util.dart';

class MeritListEntry {
  MeritListEntry({
    required this.sNo,
    required this.pdfName,
    required this.state,
    required this.year,
    required this.counsellingType,
    this.link,
  });

  final int sNo;
  final String pdfName;
  final String state;
  final String year;
  final String counsellingType;
  final String? link;

  factory MeritListEntry.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    return MeritListEntry(
      sNo: toInt(json['s_no']),
      pdfName: json['pdf_name']?.toString() ?? (json['name']?.toString() ?? ''),
      state: json['state']?.toString() ?? '',
      year: json['year']?.toString() ?? '',
      counsellingType: json['counselling_type']?.toString() ?? '',
      link: json['pdf_link']?.toString(),
    );
  }
}

class MeritListController extends GetxController {
  final RxString selectedState = ''.obs;
  final RxString selectedStateId = ''.obs;
  final RxString selectedCounsellingType = 'State'.obs;
  final RxString selectedYear = '2024'.obs;
  final RxInt entriesPerPage = 10.obs;
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxBool filtersLoading = true.obs;
  final RxString error = ''.obs;

  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  final RxList<FilterItem> counsellingTypeFilters = <FilterItem>[].obs;

  List<String> get states => stateFilters.map((e) => e.name).toList();
  List<String> get counsellingTypes => counsellingTypeFilters.isEmpty
      ? ['State', 'MCC']
      : counsellingTypeFilters.map((e) => e.name).toList();

  static const List<String> _years = ['2025', '2024', '2023', '2022', '2021'];
  static const List<int> _entriesOptions = [10, 25, 50];
  List<String> get years => _years;
  List<int> get entriesOptions => _entriesOptions;

  late final List<MeritListEntry> _allEntries;
  final RxList<MeritListEntry> filteredEntries = <MeritListEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _allEntries = <MeritListEntry>[];
    _loadFiltersThenMeritList();
  }

  /// Load states and counselling types from API (GET /common/states, GET /common/counselling-types),
  /// then set default state/year and load merit list (GET /merit-list?state_id=&year=&nLoginUserIdNo=).
  Future<void> _loadFiltersThenMeritList() async {
    filtersLoading.value = true;
    final statesFuture = FiltersApi.getStates(showLoader: false);
    final counsellingFuture = FiltersApi.getCounsellingTypes(showLoader: false);
    final (statesOk, stateList, _) = await statesFuture;
    final (ctOk, counsellingList, _) = await counsellingFuture;

    if (statesOk && stateList.isNotEmpty) {
      stateFilters.assignAll(stateList);
      if (selectedStateId.value.isEmpty) {
        selectedState.value = stateList.first.name;
        selectedStateId.value = stateList.first.id;
      } else {
        final match = stateList.where((e) => e.id == selectedStateId.value).toList();
        if (match.isNotEmpty) selectedState.value = match.first.name;
      }
    }
    if (ctOk && counsellingList.isNotEmpty) {
      counsellingTypeFilters.assignAll(counsellingList);
      if (selectedCounsellingType.value.isEmpty || !counsellingList.any((e) => e.name == selectedCounsellingType.value)) {
        selectedCounsellingType.value = counsellingList.first.name;
      }
    }
    filtersLoading.value = false;
    await loadMeritList(showLoader: true);
  }

  @override
  Future<void> refresh() async => loadMeritList(showLoader: false);

  Future<void> loadMeritList({bool showLoader = true}) async {
    error.value = '';
    isLoading.value = true;
    final extraQuery = <String, dynamic>{
      'state_id': selectedStateId.value.isEmpty ? '1' : selectedStateId.value,
      'year': selectedYear.value,
    };
    final (success, data, errorMessage) = await MeritListApi.getMeritList(
      showLoader: showLoader,
      extraQuery: extraQuery,
    );
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load merit list';
      AppSnackbar.error('Merit list', error.value);
      _allEntries.clear();
      filteredEntries.clear();
      return;
    }

    final rawList = data['merit_list'] ?? data['data'];
    final list = <MeritListEntry>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map) {
          list.add(MeritListEntry.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    _allEntries
      ..clear()
      ..addAll(list);
    _applyFilters();
  }

  void setState(String value) {
    selectedState.value = value;
    final match = stateFilters.where((e) => e.name == value).toList();
    selectedStateId.value = match.isEmpty ? '' : match.first.id;
    _applyFilters();
    loadMeritList(showLoader: false);
  }
  void setCounsellingType(String value) {
    selectedCounsellingType.value = value;
    _applyFilters();
  }
  void setYear(String value) {
    selectedYear.value = value;
    _applyFilters();
    loadMeritList(showLoader: false);
  }
  void setEntriesPerPage(int value) => entriesPerPage.value = value;
  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  void _applyFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    final list = _allEntries.where((e) {
      if (selectedState.value.isNotEmpty && e.state.isNotEmpty) {
        if (e.state != selectedState.value) return false;
      }
      if (selectedYear.value.isNotEmpty && e.year.isNotEmpty) {
        if (e.year != selectedYear.value) return false;
      }
      if (selectedCounsellingType.value.isNotEmpty && e.counsellingType.isNotEmpty) {
        if (e.counsellingType != selectedCounsellingType.value) return false;
      }
      if (q.isEmpty) return true;
      return e.pdfName.toLowerCase().contains(q) ||
          e.state.toLowerCase().contains(q) ||
          e.year.toLowerCase().contains(q) ||
          e.counsellingType.toLowerCase().contains(q);
    }).toList();
    list.sort((a, b) => a.sNo.compareTo(b.sNo));
    filteredEntries.assignAll(list.reversed.toList());
  }

  void onCheckNow(MeritListEntry entry) {
    final link = entry.link?.trim();
    if (link == null || link.isEmpty) {
      AppSnackbar.info('Merit list', 'Link not available yet.');
      return;
    }
    openLinkInBrowser(link);
  }
}
