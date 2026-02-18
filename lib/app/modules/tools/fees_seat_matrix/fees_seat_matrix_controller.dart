import 'package:get/get.dart';

import '../../../../api_services/fees_seat_matrix_api.dart';
import '../../../../api_services/filters_api.dart';
import '../../../core/snackbar/app_snackbar.dart';

class FeesSeatRow {
  FeesSeatRow({
    required this.sNo,
    required this.instituteAndType,
    required this.course,
    required this.quota,
    required this.category,
    required this.fees,
    required this.seats,
  });

  final int sNo;
  final String instituteAndType;
  final String course;
  final String quota;
  final String category;
  final String fees;
  final String seats;

  static String _instituteStr(Map<String, dynamic> json) {
    String str(dynamic v) => (v?.toString() ?? '').trim();
    final collegeName = str(json['college_name'] ?? json['institute_name'] ?? json['institute'] ?? json['institute_and_type']);
    final instituteType = str(json['institute_type_name'] ?? json['institute_type']);
    if (collegeName.isNotEmpty && instituteType.isNotEmpty) {
      return '$collegeName ($instituteType)';
    }
    return collegeName.isNotEmpty ? collegeName : instituteType;
  }

  factory FeesSeatRow.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    String str(dynamic v) => (v?.toString() ?? '').trim();
    return FeesSeatRow(
      sNo: toInt(json['s_no'] ?? json['sNo'] ?? json['serial_no']),
      instituteAndType: FeesSeatRow._instituteStr(json),
      course: str(json['course_name'] ?? json['course']),
      quota: str(json['quota_name'] ?? json['quota']),
      category: str(json['category_name'] ?? json['category'] ?? json['sm_category']),
      fees: str(json['fees'] ?? json['fee'] ?? json['fee_structure']),
      seats: str(json['seats'] ?? json['seat_count'] ?? json['total_seats']),
    );
  }
}

class FeesSeatMatrixController extends GetxController {
  final RxString selectedState = 'Select State'.obs;
  final RxString selectedStateId = ''.obs;
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
  final RxBool totalCountFromApi = false.obs;
  final RxInt paginationFromApi = 0.obs;
  final RxInt paginationToApi = 0.obs;

  final RxBool filtersLoading = true.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  final RxList<FilterItem> instituteTypeFilters = <FilterItem>[].obs;
  final RxList<FilterItem> quotaFilters = <FilterItem>[].obs;
  final RxList<FilterItem> courseFilters = <FilterItem>[].obs;
  final RxList<String> yearFilters = <String>[].obs;
  final RxList<FilterItem> clinicalTypeFilters = <FilterItem>[].obs;

  List<String> get states => stateFilters.isEmpty
      ? ['Select State', 'Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka']
      : ['Select State', ...stateFilters.map((e) => e.name)];

  List<String> get instituteTypesForDropdown => instituteTypeFilters.isEmpty
      ? ['Select Institute Type', 'Government', 'Private', 'Deemed']
      : ['Select Institute Type', ...instituteTypeFilters.map((e) => e.name)];

  List<String> get quotasForDropdown => quotaFilters.isEmpty
      ? ['Select Quota', 'General', 'OBC', 'SC', 'ST', 'EWS']
      : ['Select Quota', ...quotaFilters.map((e) => e.name)];
  static const List<String> categories = ['Select Category', 'General', 'OBC', 'SC', 'ST', 'EWS', 'N/A'];
  static const List<String> courses = ['Select Course', 'MBBS', 'BDS', 'BAMS', 'BHMS'];
  static const List<String> years = ['2024', '2023', '2022', '2021'];
  static const List<int> entriesOptions = [10, 25, 50, 100];

  static const Map<String, String> courseIds = {
    'MBBS': '1',
    'BDS': '2',
    'BAMS': '3',
    'BHMS': '4',
  };
  static const Map<String, String> instituteTypeIds = {
    'Government': '1',
    'Private': '2',
    'Deemed': '3',
  };

  List<String> get coursesForDropdown => courseFilters.isEmpty
      ? ['Select Course', ...courses.where((c) => c != 'Select Course')]
      : ['Select Course', ...courseFilters.map((e) => e.name)];

  List<String> get yearsForDropdown => yearFilters.isEmpty ? years : yearFilters;

  List<String> get clinicalTypesForDropdown => clinicalTypeFilters.isEmpty
      ? ['Select Clinical Type']
      : ['Select Clinical Type', ...clinicalTypeFilters.map((e) => e.name)];

  late List<FeesSeatRow> _allRows;
  final RxList<FeesSeatRow> filteredRows = <FeesSeatRow>[].obs;

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
    }
    await _loadInstituteTypes();
    await _loadQuotas();
    await _loadFiltersFromFeesSeatApi();
    filtersLoading.value = false;
  }

  Future<void> _loadInstituteTypes() async {
    final counsellingId = '1'; // Default counselling type
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
    final counsellingId = '1'; // Default counselling type
    
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

  Future<void> _loadFiltersFromFeesSeatApi() async {
    final stateId = stateFilters.isNotEmpty ? stateFilters.first.id : '2';
    final (success, data, _) = await FeesSeatMatrixApi.getFeesSeatMatrix(
      stateIdCounselling: '1',
      stateId: stateId,
      year: '2024',
      page: 1,
      perPage: 10,
      showLoader: false,
    );
    if (success && data != null) _parseFiltersFromResponse(data);
  }

  /// Parse filters from API response data.filters (courses, years, clinical_types) and set dropdown values.
  void _parseFiltersFromResponse(Map<String, dynamic> data) {
    final filters = data['filters'];
    if (filters is! Map) return;
    final map = Map<String, dynamic>.from(filters);

    // courses: [{ id, name }]
    final coursesList = map['courses'];
    if (coursesList is List) {
      courseFilters.assignAll(_parseFilterItemList(coursesList));
    }

    // years: [2024, 2025]
    final yearsList = map['years'];
    if (yearsList is List) {
      final years = yearsList
          .map((e) => e is int ? e.toString() : (e?.toString() ?? ''))
          .where((s) => s.isNotEmpty)
          .toList();
      yearFilters.assignAll(years);
      if (years.isNotEmpty && !years.contains(selectedYear.value)) {
        selectedYear.value = years.first;
      }
    }

    // clinical_types: [] or [{ id, name }]
    final clinicalList = map['clinical_types'];
    if (clinicalList is List) {
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
    return loadFeesSeatMatrix(showLoader: false, page: 1);
  }

  bool get canLoad => selectedStateId.value.isNotEmpty && selectedYear.value.isNotEmpty;

  Future<void> loadFeesSeatMatrix({bool showLoader = true, int? page}) async {
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
    if (clinicalTypeFilters.isNotEmpty &&
        selectedClinicalType.value.isNotEmpty &&
        selectedClinicalType.value != 'Select Clinical Type') {
      final match = clinicalTypeFilters.where((e) => e.name == selectedClinicalType.value).toList();
      clinicalTypeId = match.isNotEmpty ? match.first.id : null;
    }

    final perPage = entriesPerPage.value.clamp(1, FeesSeatMatrixApi.maxPerPage);
    final (success, data, errorMessage) = await FeesSeatMatrixApi.getFeesSeatMatrix(
      stateIdCounselling: '1',
      stateId: selectedStateId.value,
      year: selectedYear.value,
      courseId: courseId,
      clinicalTypeId: clinicalTypeId,
      page: pageToLoad,
      perPage: perPage,
      showLoader: showLoader,
    );
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load fees & seat matrix';
      AppSnackbar.error('Fees & Seat Matrix', error.value);
      _allRows = [];
      filteredRows.clear();
      totalCount.value = 0;
      totalCountFromApi.value = false;
      paginationFromApi.value = 0;
      paginationToApi.value = 0;
      return;
    }

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

    // API response: data.fees_seat_matrix = array of rows
    final rawList = data['fees_seat_matrix'] ?? data['data'] ?? data['list'] ?? data['matrix'] ?? data['seats'];
    final list = <FeesSeatRow>[];
    if (rawList is List) {
      for (var i = 0; i < rawList.length; i++) {
        final e = rawList[i];
        if (e is Map) {
          final map = Map<String, dynamic>.from(e);
          if (map['s_no'] == null && map['sNo'] == null) {
            map['s_no'] = (pageToLoad - 1) * perPage + i + 1;
          }
          list.add(FeesSeatRow.fromJson(map));
        }
      }
      if (totalCount.value == 0) totalCount.value = (pageToLoad - 1) * perPage + list.length;
    }
    _allRows = list;
    _applyFilters();
    _parseFiltersFromResponse(data);
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
    loadFeesSeatMatrix(showLoader: false, page: 1);
  }

  void setInstituteType(String v) {
    selectedInstituteType.value = v;
    _loadQuotas();
    loadFeesSeatMatrix(showLoader: false, page: 1);
  }

  void setQuota(String v) {
    selectedQuota.value = v;
    loadFeesSeatMatrix(showLoader: false, page: 1);
  }

  void setCategory(String v) => selectedCategory.value = v;

  void setCourse(String v) {
    selectedCourse.value = v;
    _loadQuotas();
    loadFeesSeatMatrix(showLoader: false, page: 1);
  }

  void setClinicalType(String v) {
    selectedClinicalType.value = v;
    if (v == 'Select Clinical Type') {
      selectedClinicalTypeId.value = '';
    } else {
      final match = clinicalTypeFilters.where((e) => e.name == v).toList();
      selectedClinicalTypeId.value = match.isEmpty ? '' : match.first.id;
    }
    loadFeesSeatMatrix(showLoader: false, page: 1);
  }

  void setYear(String v) {
    selectedYear.value = v;
    loadFeesSeatMatrix(showLoader: false, page: 1);
  }

  void setEntriesPerPage(int v) {
    entriesPerPage.value = v;
    currentPage.value = 1;
    if (canLoad) loadFeesSeatMatrix(showLoader: false, page: 1);
  }

  int get totalPages {
    final perPage = entriesPerPage.value.clamp(1, FeesSeatMatrixApi.maxPerPage);
    final total = totalCount.value;
    if (total <= 0 || perPage <= 0) return 0;
    return (total / perPage).ceil();
  }

  bool get hasNextPage {
    if (totalCountFromApi.value) return currentPage.value < totalPages;
    final perPage = entriesPerPage.value.clamp(1, FeesSeatMatrixApi.maxPerPage);
    return filteredRows.length >= perPage;
  }

  bool get hasPreviousPage => currentPage.value > 1;

  void nextPage() {
    if (hasNextPage) loadFeesSeatMatrix(showLoader: false, page: currentPage.value + 1);
  }

  void previousPage() {
    if (hasPreviousPage) loadFeesSeatMatrix(showLoader: false, page: currentPage.value - 1);
  }

  int get paginationStart {
    if (paginationFromApi.value > 0 && paginationToApi.value > 0) return paginationFromApi.value;
    final perPage = entriesPerPage.value.clamp(1, FeesSeatMatrixApi.maxPerPage);
    if (filteredRows.isEmpty) return 0;
    return (currentPage.value - 1) * perPage + 1;
  }

  int get paginationEnd {
    if (paginationFromApi.value > 0 && paginationToApi.value > 0) return paginationToApi.value;
    final perPage = entriesPerPage.value.clamp(1, FeesSeatMatrixApi.maxPerPage);
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
              r.fees.contains(q) ||
              r.seats.contains(q),
        ),
      );
    }
  }
}
