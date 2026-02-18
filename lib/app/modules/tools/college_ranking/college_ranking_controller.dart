import 'package:get/get.dart';

import '../../../../api_services/college_ranking_api.dart';
import '../../../../api_services/filters_api.dart';
import '../../../core/snackbar/app_snackbar.dart';

class CollegeRankingRow {
  CollegeRankingRow({
    required this.sNo,
    required this.instituteAndType,
    required this.state,
    required this.degreesOffered,
    required this.yearOfEstablishment,
    required this.totalSeats,
    required this.ncRanking,
  });

  final int sNo;
  final String instituteAndType;
  final String state;
  final String degreesOffered;
  final String yearOfEstablishment;
  final String totalSeats;
  final String ncRanking;

  static String _instituteStr(Map<String, dynamic> json) {
    String str(dynamic v) => (v?.toString() ?? '').trim();
    final name = str(json['college_name'] ?? json['institute_name'] ?? json['institute'] ?? json['college']);
    final type = str(json['institute_type_name'] ?? json['institute_type']);
    if (name.isNotEmpty && type.isNotEmpty) return '$name ($type)';
    return name.isNotEmpty ? name : type;
  }

  factory CollegeRankingRow.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    String str(dynamic v) => (v?.toString() ?? '').trim();
    return CollegeRankingRow(
      sNo: toInt(json['s_no'] ?? json['sNo'] ?? json['serial_no']),
      instituteAndType: CollegeRankingRow._instituteStr(json),
      state: str(json['state_name'] ?? json['state']),
      degreesOffered: str(json['degree'] ?? json['degrees_offered'] ?? json['course_name'] ?? json['course'] ?? json['courses']),
      yearOfEstablishment: str(json['establishment_year'] ?? json['year_of_establishment'] ?? json['year']),
      totalSeats: str(json['total_seats'] ?? json['seats'] ?? json['seat_count']),
      ncRanking: str(json['mm_ranking'] ?? json['nc_ranking'] ?? json['ranking'] ?? json['rank']),
    );
  }
}

class CollegeRankingController extends GetxController {
  final RxString selectedState = 'Select State'.obs;
  final RxString selectedStateId = ''.obs;
  final RxString selectedInstituteType = 'Select Institute Type'.obs;
  final RxString selectedCourse = 'Select Course'.obs;
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
  final RxList<FilterItem> courseFilters = <FilterItem>[].obs;
  final RxList<FilterItem> clinicalTypeFilters = <FilterItem>[].obs;

  List<String> get states => stateFilters.isEmpty
      ? ['Select State', 'Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka']
      : ['Select State', ...stateFilters.map((e) => e.name)];

  static const List<String> instituteTypes = ['Select Institute Type', 'Government', 'Private', 'Deemed'];
  static const List<String> courses = ['Select Course', 'MBBS', 'BDS', 'MD/MS', 'BAMS', 'BHMS'];
  static const List<int> entriesOptions = [10, 25, 50, 100];

  static const Map<String, String> courseIds = {
    'MBBS': '1',
    'BDS': '2',
    'MD/MS': '3',
    'BAMS': '4',
    'BHMS': '5',
  };

  List<String> get coursesForDropdown => courseFilters.isEmpty
      ? ['Select Course', ...courses.where((c) => c != 'Select Course')]
      : ['Select Course', ...courseFilters.map((e) => e.name)];

  List<String> get clinicalTypesForDropdown => clinicalTypeFilters.isEmpty
      ? ['Select Clinical Type']
      : ['Select Clinical Type', ...clinicalTypeFilters.map((e) => e.name)];

  late List<CollegeRankingRow> _allRows;
  final RxList<CollegeRankingRow> filteredRows = <CollegeRankingRow>[].obs;

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
    await _loadFiltersFromCollegeRankingApi();
    filtersLoading.value = false;
  }

  Future<void> _loadFiltersFromCollegeRankingApi() async {
    final stateId = stateFilters.isNotEmpty ? stateFilters.first.id : '2';
    final (success, data, _) = await CollegeRankingApi.getCollegeRanking(
      stateIdCounselling: '1',
      stateId: stateId,
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

    final coursesList = map['courses'];
    if (coursesList is List) {
      courseFilters.assignAll(_parseFilterItemList(coursesList));
    }

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
    return loadCollegeRanking(showLoader: false, page: 1);
  }

  bool get canLoad => selectedStateId.value.isNotEmpty;

  Future<void> loadCollegeRanking({bool showLoader = true, int? page}) async {
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

    final perPage = entriesPerPage.value.clamp(1, CollegeRankingApi.maxPerPage);
    final (success, data, errorMessage) = await CollegeRankingApi.getCollegeRanking(
      stateIdCounselling: '1',
      stateId: selectedStateId.value,
      courseId: courseId,
      clinicalTypeId: clinicalTypeId,
      page: pageToLoad,
      perPage: perPage,
      showLoader: showLoader,
    );
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load college ranking';
      AppSnackbar.error('College Ranking', error.value);
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
      paginationFromApi.value = map['from'] is int ? map['from'] as int : int.tryParse(map['from']?.toString() ?? '') ?? 0;
      paginationToApi.value = map['to'] is int ? map['to'] as int : int.tryParse(map['to']?.toString() ?? '') ?? 0;
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

    // API response: data.colleges = array of ranking rows
    final rawList = data['colleges'] ?? data['college_ranking'] ?? data['data'] ?? data['list'] ?? data['rankings'];
    final list = <CollegeRankingRow>[];
    if (rawList is List) {
      for (var i = 0; i < rawList.length; i++) {
        final e = rawList[i];
        if (e is Map) {
          final map = Map<String, dynamic>.from(e);
          if (map['s_no'] == null && map['sNo'] == null) {
            map['s_no'] = (pageToLoad - 1) * perPage + i + 1;
          }
          list.add(CollegeRankingRow.fromJson(map));
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
    loadCollegeRanking(showLoader: false, page: 1);
  }

  void setInstituteType(String v) => selectedInstituteType.value = v;

  void setCourse(String v) {
    selectedCourse.value = v;
    loadCollegeRanking(showLoader: false, page: 1);
  }

  void setClinicalType(String v) {
    selectedClinicalType.value = v;
    if (v == 'Select Clinical Type') {
      selectedClinicalTypeId.value = '';
    } else {
      final match = clinicalTypeFilters.where((e) => e.name == v).toList();
      selectedClinicalTypeId.value = match.isEmpty ? '' : match.first.id;
    }
    loadCollegeRanking(showLoader: false, page: 1);
  }

  void setEntriesPerPage(int v) {
    entriesPerPage.value = v;
    currentPage.value = 1;
    if (canLoad) loadCollegeRanking(showLoader: false, page: 1);
  }

  int get totalPages {
    final perPage = entriesPerPage.value.clamp(1, CollegeRankingApi.maxPerPage);
    final total = totalCount.value;
    if (total <= 0 || perPage <= 0) return 0;
    return (total / perPage).ceil();
  }

  bool get hasNextPage {
    if (totalCountFromApi.value) return currentPage.value < totalPages;
    final perPage = entriesPerPage.value.clamp(1, CollegeRankingApi.maxPerPage);
    return filteredRows.length >= perPage;
  }

  bool get hasPreviousPage => currentPage.value > 1;

  void nextPage() {
    if (hasNextPage) loadCollegeRanking(showLoader: false, page: currentPage.value + 1);
  }

  void previousPage() {
    if (hasPreviousPage) loadCollegeRanking(showLoader: false, page: currentPage.value - 1);
  }

  int get paginationStart {
    if (paginationFromApi.value > 0 && paginationToApi.value > 0) return paginationFromApi.value;
    final perPage = entriesPerPage.value.clamp(1, CollegeRankingApi.maxPerPage);
    if (filteredRows.isEmpty) return 0;
    return (currentPage.value - 1) * perPage + 1;
  }

  int get paginationEnd {
    if (paginationFromApi.value > 0 && paginationToApi.value > 0) return paginationToApi.value;
    final perPage = entriesPerPage.value.clamp(1, CollegeRankingApi.maxPerPage);
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
              r.state.toLowerCase().contains(q) ||
              r.degreesOffered.toLowerCase().contains(q) ||
              r.yearOfEstablishment.contains(q) ||
              r.totalSeats.contains(q) ||
              r.ncRanking.contains(q),
        ),
      );
    }
  }
}
