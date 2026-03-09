import 'package:get/get.dart';

import '../../../../api_services/cut_off_allotments_api.dart';
import '../../../../api_services/filters_api.dart';
import '../../../core/snackbar/app_snackbar.dart';

class CutoffRow {
  CutoffRow({
    required this.sNo,
    required this.instituteAndType,
    required this.course,
    required this.quota,
    required this.category,
    required this.fees,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.r4,
  });

  final int sNo;
  final String instituteAndType;
  final String course;
  final String quota;
  final String category;
  final String fees;
  final String r1;
  final String r2;
  final String r3;
  final String r4;

  static String _instituteStr(Map<String, dynamic> json) {
    String str(dynamic v) => (v?.toString() ?? '').trim();
    final collegeName = str(json['college_name'] ?? json['institute_name'] ?? json['institute'] ?? json['institute_and_type']);
    final instituteType = str(json['institute_type_name'] ?? json['institute_type']);
    if (collegeName.isNotEmpty && instituteType.isNotEmpty) {
      return '$collegeName ($instituteType)';
    }
    return collegeName.isNotEmpty ? collegeName : instituteType;
  }

  factory CutoffRow.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    String str(dynamic v) => (v?.toString() ?? '').trim();
    
    // Handle nested rounds object
    final rounds = json['rounds'];
    String getRound(String key) {
      if (rounds is Map) {
        final value = rounds[key];
        return value == null ? '-' : str(value);
      }
      return str(json[key] ?? json['round${key.substring(1)}'] ?? json['round_${key.substring(1)}']);
    }
    
    return CutoffRow(
      sNo: toInt(json['s_no'] ?? json['sNo'] ?? json['serial_no']),
      instituteAndType: CutoffRow._instituteStr(json),
      course: str(json['course_name'] ?? json['course']),
      quota: str(json['quota_name'] ?? json['quota']),
      category: str(json['category_name'] ?? json['category'] ?? json['sm_category']),
      fees: str(json['fees'] ?? json['fee'] ?? json['fee_structure']),
      r1: getRound('r1'),
      r2: getRound('r2'),
      r3: getRound('r3'),
      r4: getRound('r4'),
    );
  }
}

class CutoffAllotmentsController extends GetxController {
  final RxString selectedState = 'Select State'.obs;
  final RxString selectedStateId = ''.obs;
  final RxString selectedCounsellingType = 'State'.obs;
  final RxString selectedCounsellingTypeId = '1'.obs; // Default to '1' (State counselling)
  final RxString selectedInstituteType = 'Select Institute Type'.obs;
  final RxString selectedQuota = 'Select Quota'.obs;
  final RxString selectedCategory = 'Select Category'.obs;
  final RxString selectedCourse = 'Select Course'.obs;
  final RxString selectedYear = '2024'.obs;
  final RxString selectedClinicalType = 'Select Clinical Type'.obs;
  final RxString selectedClinicalTypeId = ''.obs;
  final RxInt entriesPerPage = 10.obs;
  final RxString searchQuery = ''.obs;
  final RxInt currentPage = 1.obs;
  final RxInt totalCount = 0.obs;
  /// True when totalCount was set from API response; false when inferred from current page size.
  final RxBool totalCountFromApi = false.obs;
  /// When API returns pagination.from and pagination.to, use these for "Showing X-Y"
  final RxInt paginationFromApi = 0.obs;
  final RxInt paginationToApi = 0.obs;

  final RxBool filtersLoading = true.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  final RxList<FilterItem> instituteTypeFilters = <FilterItem>[].obs;
  final RxList<FilterItem> quotaFilters = <FilterItem>[].obs;
  List<String> get states => stateFilters.isEmpty
      ? ['Select State', 'Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka']
      : ['Select State', ...stateFilters.map((e) => e.name)];

  List<String> get instituteTypesForDropdown => instituteTypeFilters.isEmpty
      ? ['Select Institute Type', 'Government', 'Private', 'Deemed']
      : ['Select Institute Type', ...instituteTypeFilters.map((e) => e.name)];

  List<String> get quotasForDropdown => quotaFilters.isEmpty
      ? ['Select Quota', 'General', 'OBC', 'SC', 'ST', 'EWS']
      : ['Select Quota', ...quotaFilters.map((e) => e.name)];

  List<String> get categoriesForDropdown => categoryFilters.isEmpty
      ? ['Select Category']
      : ['Select Category', ...categoryFilters.map((e) => e.name)];

  static const List<String> courses = ['Select Course', 'MBBS', 'BDS', 'BAMS', 'BHMS'];
  static const List<String> years = ['2024', '2023', '2022', '2021'];
  static const List<int> entriesOptions = [10, 25, 50, 100];

  static const Map<String, String> instituteTypeIds = {
    'Government': '1',
    'Private': '2',
    'Deemed': '3',
  };
  static const Map<String, String> quotaIds = {
    'General': '1',
    'OBC': '2',
    'SC': '3',
    'ST': '4',
    'EWS': '5',
  };
  static const Map<String, String> courseIds = {
    'MBBS': '1',
    'BDS': '2',
    'BAMS': '3',
    'BHMS': '4',
  };

  List<int> get entriesOptionsList => entriesOptions;

  late List<CutoffRow> _allRows;
  final RxList<CutoffRow> filteredRows = <CutoffRow>[].obs;

  final RxList<FilterItem> counsellingTypeFilters = <FilterItem>[].obs;
  final RxList<FilterItem> courseFilters = <FilterItem>[].obs;
  final RxList<String> yearFilters = <String>[].obs;
  final RxList<FilterItem> clinicalTypeFilters = <FilterItem>[].obs;
  final RxList<FilterItem> categoryFilters = <FilterItem>[].obs;

  List<String> get counsellingTypesForDropdown => counsellingTypeFilters.isEmpty
      ? ['State', 'MCC']
      : counsellingTypeFilters.map((e) => e.name).toList();

  List<String> get coursesForDropdown => courseFilters.isEmpty
      ? ['Select Course', ...CutoffAllotmentsController.courses.where((c) => c != 'Select Course')]
      : ['Select Course', ...courseFilters.map((e) => e.name)];

  List<String> get yearsForDropdown => yearFilters.isEmpty
      ? CutoffAllotmentsController.years
      : yearFilters;

  List<String> get clinicalTypesForDropdown => clinicalTypeFilters.isEmpty
      ? ['Select Clinical Type']
      : ['Select Clinical Type', ...clinicalTypeFilters.map((e) => e.name)];

  @override
  void onInit() {
    super.onInit();
    _allRows = [];
    _loadFilters();
  }

  Future<void> _loadFilters() async {
    filtersLoading.value = true;
    final (statesOk, stateList, _) = await FiltersApi.getStates(showLoader: false);
    if (statesOk && stateList.isNotEmpty) {
      stateFilters.assignAll(stateList);
      // Set default state to Uttar Pradesh
      if (selectedState.value == 'Select State' || selectedStateId.value.isEmpty) {
        final upState = stateList.where((e) => 
          e.name.toLowerCase().contains('uttar pradesh') || 
          e.name.toLowerCase().contains('up') ||
          e.name.toLowerCase() == 'up'
        ).toList();
        if (upState.isNotEmpty) {
          selectedState.value = upState.first.name;
          selectedStateId.value = upState.first.id;
        } else if (stateList.isNotEmpty) {
          selectedState.value = stateList.first.name;
          selectedStateId.value = stateList.first.id;
        }
      }
    }
    await _loadInstituteTypes();
    await _loadQuotas();
    await _loadCategories();
    await _loadFiltersFromCutOffApi();
    filtersLoading.value = false;
    if (canLoad) {
      await loadCutOffAllotments(showLoader: false, page: 1);
    }
  }

  /// Load category options from /common/dependent-filters for the selected quota.
  Future<void> _loadCategories() async {
    String? quotaId;
    if (selectedQuota.value.isNotEmpty && selectedQuota.value != 'Select Quota') {
      final match = quotaFilters.where((e) => e.name == selectedQuota.value).toList();
      quotaId = match.isNotEmpty ? match.first.id : null;
    }
    if (quotaId == null && quotaFilters.isNotEmpty) {
      quotaId = quotaFilters.first.id;
    }
    if (quotaId == null || quotaId.isEmpty) {
      categoryFilters.clear();
      return;
    }
    final (success, list, _) = await FiltersApi.getDependentFilters(
      quotaId: quotaId,
      showLoader: false,
    );
    if (success && list.isNotEmpty) {
      categoryFilters.assignAll(list);
    } else {
      categoryFilters.clear();
    }
  }

  Future<void> _loadInstituteTypes() async {
    final counsellingId = selectedCounsellingTypeId.value.isNotEmpty ? selectedCounsellingTypeId.value : '1';
    final (success, list, _) = await FiltersApi.getInstituteTypes(
      counsellingId: counsellingId,
      showLoader: false,
    );
    if (success && list.isNotEmpty) {
      instituteTypeFilters.assignAll(list);
    }
  }

  Future<void> _loadQuotas() async {
    // All parameters are required, so provide defaults if not selected
    final counsellingId = selectedCounsellingTypeId.value.isNotEmpty ? selectedCounsellingTypeId.value : '0';
    
    // state_id is required - use first state if none selected, or '0' as fallback
    String stateId = selectedStateId.value.isNotEmpty 
        ? selectedStateId.value 
        : (stateFilters.isNotEmpty ? stateFilters.first.id : '0');
    
    // institute_type_id is required - use first institute type if none selected, or '0' as fallback
    String instituteTypeId = '0';
    if (selectedInstituteType.value.isNotEmpty && selectedInstituteType.value != 'Select Institute Type') {
      if (instituteTypeFilters.isNotEmpty) {
        final match = instituteTypeFilters.where((e) => e.name == selectedInstituteType.value).toList();
        instituteTypeId = match.isNotEmpty ? match.first.id : (instituteTypeIds[selectedInstituteType.value] ?? '0');
      } else {
        instituteTypeId = instituteTypeIds[selectedInstituteType.value] ?? '0';
      }
    } else if (instituteTypeFilters.isNotEmpty) {
      instituteTypeId = instituteTypeFilters.first.id;
    }
    
    // course_type_id is required - use first course if none selected, or '0' as fallback
    String courseTypeId = '0';
    if (selectedCourse.value.isNotEmpty && selectedCourse.value != 'Select Course') {
      if (courseFilters.isNotEmpty) {
        final match = courseFilters.where((e) => e.name == selectedCourse.value).toList();
        courseTypeId = match.isNotEmpty ? match.first.id : (courseIds[selectedCourse.value] ?? '0');
      } else {
        courseTypeId = courseIds[selectedCourse.value] ?? '0';
      }
    } else if (courseFilters.isNotEmpty) {
      courseTypeId = courseFilters.first.id;
    }
    
    final (success, list, _) = await FiltersApi.getQuota(
      counsellingId: counsellingId,
      stateId: stateId,
      instituteTypeId: instituteTypeId,
      courseTypeId: courseTypeId,
      showLoader: false,
    );
    if (success && list.isNotEmpty) {
      quotaFilters.assignAll(list);
    }
  }

  /// Load filter options (counselling_types, courses, years, clinical_types) from cut-off allotments API.
  /// Uses default state/year so we can get filters when user lands on page; data is loaded after user applies filters.
  Future<void> _loadFiltersFromCutOffApi() async {
    final stateId = stateFilters.isNotEmpty ? stateFilters.first.id : '2';
    final (success, data, _) = await CutOffAllotmentsApi.getCutOffAllotments(
      stateIdCounselling: '1',
      stateId: stateId,
      year: '2024',
      page: 1,
      perPage: 10,
      showLoader: false,
    );
    if (success && data != null) _parseFiltersFromResponse(data);
  }

  void _parseFiltersFromResponse(Map<String, dynamic> data) {
    final filters = data['filters'];
    if (filters is! Map) return;
    final map = Map<String, dynamic>.from(filters);

    final ctList = map['counselling_types'];
    if (ctList is List && ctList.isNotEmpty) {
      final list = _parseFilterItemList(ctList);
      if (list.isNotEmpty) {
        counsellingTypeFilters.assignAll(list);
        // Set default counselling type if not set or if current selection is not in the list
        if (selectedCounsellingTypeId.value.isEmpty || 
            !list.any((e) => e.id == selectedCounsellingTypeId.value) ||
            !list.any((e) => e.name == selectedCounsellingType.value)) {
          selectedCounsellingType.value = list.first.name;
          selectedCounsellingTypeId.value = list.first.id;
        } else {
          // Ensure selected value matches the filter item
          final match = list.where((e) => e.id == selectedCounsellingTypeId.value).toList();
          if (match.isNotEmpty) {
            selectedCounsellingType.value = match.first.name;
          }
        }
      }
    }

    final coursesList = map['courses'];
    if (coursesList is List && coursesList.isNotEmpty) {
      courseFilters.assignAll(_parseFilterItemList(coursesList));
    }

    final yearsList = map['years'];
    if (yearsList is List && yearsList.isNotEmpty) {
      yearFilters.assignAll(
        yearsList.map((e) => e is int ? e.toString() : (e?.toString() ?? '')).where((s) => s.isNotEmpty).toList(),
      );
      if (yearFilters.isNotEmpty && !yearFilters.contains(selectedYear.value)) {
        selectedYear.value = yearFilters.first;
      }
    }

    final clinicalList = map['clinical_types'];
    if (clinicalList is List && clinicalList.isNotEmpty) {
      clinicalTypeFilters.assignAll(_parseFilterItemList(clinicalList));
    }
  }

  static List<FilterItem> _parseFilterItemList(dynamic raw) {
    final list = <FilterItem>[];
    if (raw is! List) return list;
    for (final e in raw) {
      if (e is Map) {
        final m = Map<String, dynamic>.from(e);
        final id = (m['id']?.toString() ?? '').trim();
        final name = (m['name']?.toString() ?? '').trim();
        if (name.isNotEmpty) list.add(FilterItem(id: id, name: name));
      }
    }
    return list;
  }

  @override
  Future<void> refresh() async {
    currentPage.value = 1;
    return loadCutOffAllotments(showLoader: false, page: 1);
  }

  bool get canLoad =>
      selectedCounsellingTypeId.value.isNotEmpty &&
      selectedStateId.value.isNotEmpty &&
      selectedYear.value.isNotEmpty;

  Future<void> loadCutOffAllotments({bool showLoader = true, int? page}) async {
    if (!canLoad) {
      _allRows = [];
      filteredRows.clear();
      totalCount.value = 0;
      return;
    }
    final pageToLoad = page ?? currentPage.value;
    if (pageToLoad < 1) return;
    currentPage.value = pageToLoad;
    error.value = '';
    isLoading.value = true;
    final instituteTypeId = selectedInstituteType.value.isNotEmpty && instituteTypeIds.containsKey(selectedInstituteType.value)
        ? instituteTypeIds[selectedInstituteType.value]
        : null;
    String? courseId;
    if (selectedCourse.value.isNotEmpty && selectedCourse.value != 'Select Course') {
      if (courseFilters.isNotEmpty) {
        final match = courseFilters.where((e) => e.name == selectedCourse.value).toList();
        courseId = match.isNotEmpty ? match.first.id : courseIds[selectedCourse.value];
      } else {
        courseId = courseIds[selectedCourse.value];
      }
    }
    String? clinicalTypeId;
    if (clinicalTypeFilters.isNotEmpty && selectedClinicalType.value.isNotEmpty && selectedClinicalType.value != 'Select Clinical Type') {
      final match = clinicalTypeFilters.where((e) => e.name == selectedClinicalType.value).toList();
      clinicalTypeId = match.isNotEmpty ? match.first.id : null;
    }
    String? quotaId;
    if (selectedQuota.value.isNotEmpty && selectedQuota.value != 'Select Quota') {
      if (quotaFilters.isNotEmpty) {
        final match = quotaFilters.where((e) => e.name == selectedQuota.value).toList();
        quotaId = match.isNotEmpty ? match.first.id : quotaIds[selectedQuota.value];
      } else {
        quotaId = quotaIds[selectedQuota.value];
      }
    }
    String? smCategoryId;
    if (selectedCategory.value.isNotEmpty && selectedCategory.value != 'Select Category') {
      if (categoryFilters.isNotEmpty) {
        final match = categoryFilters.where((e) => e.name == selectedCategory.value).toList();
        smCategoryId = match.isNotEmpty ? match.first.id : null;
      }
    }

    final perPage = entriesPerPage.value.clamp(1, CutOffAllotmentsApi.maxPerPage);
    final (success, data, errorMessage) = await CutOffAllotmentsApi.getCutOffAllotments(
      stateIdCounselling: selectedCounsellingTypeId.value,
      stateId: selectedStateId.value,
      year: selectedYear.value,
      instituteTypeId: instituteTypeId,
      courseId: courseId,
      quotaId: quotaId,
      smCategoryId: smCategoryId,
      clinicalTypeId: clinicalTypeId,
      page: pageToLoad,
      perPage: perPage,
      showLoader: showLoader,
    );
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load cut-off allotments';
      AppSnackbar.error('Cut-off allotments', error.value);
      _allRows = [];
      filteredRows.clear();
      totalCount.value = 0;
      totalCountFromApi.value = false;
      paginationFromApi.value = 0;
      paginationToApi.value = 0;
      return;
    }

    // Parse pagination from API (e.g. pagination: { current_page, per_page, total, total_pages, from, to })
    final pagination = data['pagination'];
    if (pagination is Map) {
      final map = Map<String, dynamic>.from(pagination);
      final rawTotal = map['total'];
      if (rawTotal != null) {
        totalCount.value = rawTotal is int ? rawTotal : int.tryParse(rawTotal.toString()) ?? 0;
        totalCountFromApi.value = true;
      }
      final fromVal = map['from'];
      final toVal = map['to'];
      paginationFromApi.value = fromVal is int ? fromVal : int.tryParse(fromVal?.toString() ?? '') ?? 0;
      paginationToApi.value = toVal is int ? toVal : int.tryParse(toVal?.toString() ?? '') ?? 0;
    } else {
      final rawTotal = data['total'] ?? data['total_count'] ?? data['totalCount'] ?? data['total_records'];
      if (rawTotal != null) {
        totalCount.value = rawTotal is int ? rawTotal : int.tryParse(rawTotal.toString()) ?? 0;
        totalCountFromApi.value = true;
      } else {
        totalCountFromApi.value = false;
      }
      paginationFromApi.value = 0;
      paginationToApi.value = 0;
    }

    // API may return list in data.data (paginated) or data.cutoffs / data.list
    final rawList = data['data'] ?? data['cutoffs'] ?? data['list'] ?? data['cut_off_allotments'] ?? data['allotments'];
    final list = <CutoffRow>[];
    if (rawList is List) {
      for (var i = 0; i < rawList.length; i++) {
        final e = rawList[i];
        if (e is Map) {
          final map = Map<String, dynamic>.from(e);
          if (map['s_no'] == null && map['sNo'] == null) map['s_no'] = (pageToLoad - 1) * perPage + i + 1;
          list.add(CutoffRow.fromJson(map));
        }
      }
      if (totalCount.value == 0) totalCount.value = (pageToLoad - 1) * perPage + list.length;
    }
    _allRows = list;
    _applyFilters();
    _parseFiltersFromResponse(data);
  }

  void setCounsellingType(String v) {
    selectedCounsellingType.value = v;
    // Update counselling type ID (assuming 'State' = '1', 'MCC' = '2', etc.)
    if (counsellingTypeFilters.isNotEmpty) {
      final match = counsellingTypeFilters.where((e) => e.name == v).toList();
      selectedCounsellingTypeId.value = match.isNotEmpty ? match.first.id : '1';
    } else {
      selectedCounsellingTypeId.value = v == 'MCC' ? '2' : '1';
    }
    _loadQuotas();
    final match = counsellingTypeFilters.where((e) => e.name == v).toList();
    selectedCounsellingTypeId.value = match.isEmpty ? '1' : match.first.id;
    loadCutOffAllotments(showLoader: false, page: 1);
  }

  void setState(String v) {
    selectedState.value = v;
    if (v == 'Select State') {
      selectedStateId.value = '';
    } else {
      final match = stateFilters.where((e) => e.name == v).toList();
      selectedStateId.value = match.isEmpty ? '' : match.first.id;
    }
    _loadQuotas();
    loadCutOffAllotments(showLoader: false, page: 1);
  }

  void setInstituteType(String v) {
    selectedInstituteType.value = v;
    // Reset dependent filters when institute type changes
    selectedQuota.value = 'Select Quota';
    selectedCategory.value = 'Select Category';
    categoryFilters.clear();
    _loadQuotas();
    loadCutOffAllotments(showLoader: false, page: 1);
  }

  void setQuota(String v) {
    selectedQuota.value = v;
    // Reset category when quota changes
    selectedCategory.value = 'Select Category';
    _loadQuotas();
    _loadCategories();
    loadCutOffAllotments(showLoader: false, page: 1);
  }

  void setCategory(String v) {
    selectedCategory.value = v;
    loadCutOffAllotments(showLoader: false, page: 1);
  }

  void setCourse(String v) {
    selectedCourse.value = v;
    _loadQuotas();
    loadCutOffAllotments(showLoader: false, page: 1);
  }

  void setClinicalType(String v) {
    selectedClinicalType.value = v;
    if (v == 'Select Clinical Type') {
      selectedClinicalTypeId.value = '';
    } else {
      final match = clinicalTypeFilters.where((e) => e.name == v).toList();
      selectedClinicalTypeId.value = match.isEmpty ? '' : match.first.id;
    }
    loadCutOffAllotments(showLoader: false, page: 1);
  }

  void setYear(String v) {
    selectedYear.value = v;
    loadCutOffAllotments(showLoader: false, page: 1);
  }

  void setEntriesPerPage(int v) {
    entriesPerPage.value = v;
    currentPage.value = 1;
    if (canLoad) loadCutOffAllotments(showLoader: false, page: 1);
  }

  int get totalPages {
    final perPage = entriesPerPage.value.clamp(1, CutOffAllotmentsApi.maxPerPage);
    final total = totalCount.value;
    if (total <= 0 || perPage <= 0) return 0;
    return (total / perPage).ceil();
  }

  bool get hasNextPage {
    if (totalCountFromApi.value) return currentPage.value < totalPages;
    // When API doesn't send total: show Next if current page is full (more may exist)
    final perPage = entriesPerPage.value.clamp(1, CutOffAllotmentsApi.maxPerPage);
    return filteredRows.length >= perPage;
  }

  bool get hasPreviousPage => currentPage.value > 1;

  void nextPage() {
    if (hasNextPage) loadCutOffAllotments(showLoader: false, page: currentPage.value + 1);
  }

  void previousPage() {
    if (hasPreviousPage) loadCutOffAllotments(showLoader: false, page: currentPage.value - 1);
  }

  void goToPage(int page) {
    if (page < 1 || page > totalPages) return;
    loadCutOffAllotments(showLoader: false, page: page);
  }

  /// 1-based start index for "Showing X-Y of Z" (uses API pagination.from when available)
  int get paginationStart {
    if (paginationFromApi.value > 0 && paginationToApi.value > 0) return paginationFromApi.value;
    final perPage = entriesPerPage.value.clamp(1, CutOffAllotmentsApi.maxPerPage);
    if (filteredRows.isEmpty) return 0;
    return (currentPage.value - 1) * perPage + 1;
  }

  /// 1-based end index for "Showing X-Y of Z" (uses API pagination.to when available)
  int get paginationEnd {
    if (paginationFromApi.value > 0 && paginationToApi.value > 0) return paginationToApi.value;
    final perPage = entriesPerPage.value.clamp(1, CutOffAllotmentsApi.maxPerPage);
    final count = filteredRows.length;
    if (count == 0) return 0;
    return (currentPage.value - 1) * perPage + count;
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  void _applyFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredRows.assignAll(_allRows);
    } else {
      filteredRows.assignAll(
        _allRows.where(
          (r) =>
              r.instituteAndType.toLowerCase().contains(q) ||
              r.course.toLowerCase().contains(q) ||
              r.quota.toLowerCase().contains(q) ||
              r.category.toLowerCase().contains(q) ||
              r.fees.contains(q),
        ),
      );
    }
  }

}
