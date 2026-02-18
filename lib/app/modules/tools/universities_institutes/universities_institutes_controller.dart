import 'package:get/get.dart';

import '../../../../api_services/filters_api.dart';
import '../../../../api_services/universities_institutes_api.dart';
import '../../../core/snackbar/app_snackbar.dart';

class UniversitiesInstitutesRow {
  UniversitiesInstitutesRow({
    required this.sNo,
    required this.instituteAndType,
    required this.university,
    required this.authority,
    required this.bondPenalty,
    required this.bedsCount,
    this.officialWebsiteUrl,
    this.registrationUrl,
    this.prospectsUrl,
  });

  final int sNo;
  final String instituteAndType;
  final String university;
  final String authority;
  final String bondPenalty;
  final String bedsCount;
  final String? officialWebsiteUrl;
  final String? registrationUrl;
  final String? prospectsUrl;

  static String _instituteStr(Map<String, dynamic> json) {
    String str(dynamic v) => (v?.toString() ?? '').trim();
    final name = str(json['name'] ?? json['college_name'] ?? json['institute_name'] ?? json['institute'] ?? json['college']);
    final type = str(json['institute_type_name'] ?? json['institute_type']);
    if (name.isNotEmpty && type.isNotEmpty) return '$name ($type)';
    return name.isNotEmpty ? name : type;
  }

  factory UniversitiesInstitutesRow.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    String str(dynamic v) => (v?.toString() ?? '').trim();
    String? strOrNull(dynamic v) {
      if (v == null) return null;
      final s = (v.toString()).trim();
      return s.isEmpty ? null : s;
    }
    return UniversitiesInstitutesRow(
      sNo: toInt(json['s_no'] ?? json['sNo'] ?? json['serial_no']),
      instituteAndType: UniversitiesInstitutesRow._instituteStr(json),
      university: str(json['university_name'] ?? json['university']),
      authority: str(json['authority_name'] ?? json['authority'] ?? json['regulating_authority']),
      bondPenalty: str(json['bond_penalty__name'] ?? json['bond_penalty'] ?? json['bond']),
      bedsCount: str(json['bed_count'] ?? json['beds_count'] ?? json['beds'] ?? json['total_beds']),
      officialWebsiteUrl: strOrNull(json['official_website'] ?? json['website_url'] ?? json['website'] ?? json['official_website_url']),
      registrationUrl: strOrNull(json['registration'] ?? json['registration_url'] ?? json['registration_link'] ?? json['registrationUrl']),
      prospectsUrl: strOrNull(json['prospects'] ?? json['prospects_url'] ?? json['prospects_link'] ?? json['prospectsUrl']),
    );
  }
}

class UniversitiesInstitutesController extends GetxController {
  final RxString selectedState = 'Select State'.obs;
  final RxString selectedStateId = ''.obs;
  final RxString selectedInstituteType = 'Select Institute Type'.obs;
  final RxString selectedUniversity = 'Select University'.obs;
  final RxString selectedUniversityId = ''.obs;
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
  final RxList<FilterItem> universityFilters = <FilterItem>[].obs;

  List<String> get states => stateFilters.isEmpty
      ? ['Select State', 'Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka']
      : ['Select State', ...stateFilters.map((e) => e.name)];

  static const List<String> instituteTypes = ['Select Institute Type', 'Government', 'Private', 'Deemed'];
  static const List<int> entriesOptions = [10, 25, 50, 100];

  static const Map<String, String> instituteTypeIds = {
    'Government': '1',
    'Private': '2',
    'Deemed': '3',
  };

  List<String> get instituteTypesForDropdown => instituteTypeFilters.isEmpty
      ? instituteTypes
      : ['Select Institute Type', ...instituteTypeFilters.map((e) => e.name)];

  List<String> get universitiesForDropdown => universityFilters.isEmpty
      ? ['Select University', 'Sharda University Greater Noida UP', 'Dr. Ram Manohar Lohia Avadh University', 'Other University']
      : ['Select University', ...universityFilters.map((e) => e.name)];

  late List<UniversitiesInstitutesRow> _allRows;
  final RxList<UniversitiesInstitutesRow> filteredRows = <UniversitiesInstitutesRow>[].obs;

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
    await _loadFiltersFromUniversitiesInstitutesApi();
    filtersLoading.value = false;
  }

  Future<void> _loadFiltersFromUniversitiesInstitutesApi() async {
    final stateId = stateFilters.isNotEmpty ? stateFilters.first.id : '2';
    final (success, data, _) = await UniversitiesInstitutesApi.getUniversitiesInstitutes(
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

    final instituteList = map['institute_types'] ?? map['institute_types_list'];
    if (instituteList is List && instituteList.isNotEmpty) {
      instituteTypeFilters.assignAll(_parseFilterItemList(instituteList));
    }

    final univList = map['universities'] ?? map['university_list'];
    if (univList is List && univList.isNotEmpty) {
      universityFilters.assignAll(_parseFilterItemList(univList));
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
    return loadUniversitiesInstitutes(showLoader: false, page: 1);
  }

  bool get canLoad => selectedStateId.value.isNotEmpty;

  Future<void> loadUniversitiesInstitutes({bool showLoader = true, int? page}) async {
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

    String? instituteTypeId;
    if (selectedInstituteType.value.isNotEmpty && selectedInstituteType.value != 'Select Institute Type') {
      if (instituteTypeFilters.isNotEmpty) {
        final match = instituteTypeFilters.where((e) => e.name == selectedInstituteType.value).toList();
        instituteTypeId = match.isNotEmpty ? match.first.id : instituteTypeIds[selectedInstituteType.value];
      } else {
        instituteTypeId = instituteTypeIds[selectedInstituteType.value];
      }
    }

    String? universityId;
    if (selectedUniversity.value.isNotEmpty && selectedUniversity.value != 'Select University') {
      if (universityFilters.isNotEmpty) {
        final match = universityFilters.where((e) => e.name == selectedUniversity.value).toList();
        universityId = match.isNotEmpty ? match.first.id : null;
      }
    }

    final perPage = entriesPerPage.value.clamp(1, UniversitiesInstitutesApi.maxPerPage);
    final (success, data, errorMessage) = await UniversitiesInstitutesApi.getUniversitiesInstitutes(
      stateIdCounselling: '1',
      stateId: selectedStateId.value,
      instituteTypeId: instituteTypeId,
      universityId: universityId,
      page: pageToLoad,
      perPage: perPage,
      showLoader: showLoader,
    );
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load universities & institutes';
      AppSnackbar.error('Universities & Institutes', error.value);
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

    // API response: data.colleges = array of institute rows
    final rawList = data['colleges'] ?? data['institutes'] ?? data['universities_institutes'] ?? data['data'] ?? data['list'] ?? data['universities'];
    final list = <UniversitiesInstitutesRow>[];
    if (rawList is List) {
      for (var i = 0; i < rawList.length; i++) {
        final e = rawList[i];
        if (e is Map) {
          final map = Map<String, dynamic>.from(e);
          if (map['s_no'] == null && map['sNo'] == null) {
            map['s_no'] = (pageToLoad - 1) * perPage + i + 1;
          }
          list.add(UniversitiesInstitutesRow.fromJson(map));
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
    loadUniversitiesInstitutes(showLoader: false, page: 1);
  }

  void setInstituteType(String v) {
    selectedInstituteType.value = v;
    loadUniversitiesInstitutes(showLoader: false, page: 1);
  }

  void setUniversity(String v) {
    selectedUniversity.value = v;
    if (v == 'Select University') {
      selectedUniversityId.value = '';
    } else {
      final match = universityFilters.where((e) => e.name == v).toList();
      selectedUniversityId.value = match.isEmpty ? '' : match.first.id;
    }
    loadUniversitiesInstitutes(showLoader: false, page: 1);
  }

  void setEntriesPerPage(int v) {
    entriesPerPage.value = v;
    currentPage.value = 1;
    if (canLoad) loadUniversitiesInstitutes(showLoader: false, page: 1);
  }

  int get totalPages {
    final perPage = entriesPerPage.value.clamp(1, UniversitiesInstitutesApi.maxPerPage);
    final total = totalCount.value;
    if (total <= 0 || perPage <= 0) return 0;
    return (total / perPage).ceil();
  }

  bool get hasNextPage {
    if (totalCountFromApi.value) return currentPage.value < totalPages;
    final perPage = entriesPerPage.value.clamp(1, UniversitiesInstitutesApi.maxPerPage);
    return filteredRows.length >= perPage;
  }

  bool get hasPreviousPage => currentPage.value > 1;

  void nextPage() {
    if (hasNextPage) loadUniversitiesInstitutes(showLoader: false, page: currentPage.value + 1);
  }

  void previousPage() {
    if (hasPreviousPage) loadUniversitiesInstitutes(showLoader: false, page: currentPage.value - 1);
  }

  int get paginationStart {
    if (paginationFromApi.value > 0 && paginationToApi.value > 0) return paginationFromApi.value;
    final perPage = entriesPerPage.value.clamp(1, UniversitiesInstitutesApi.maxPerPage);
    if (filteredRows.isEmpty) return 0;
    return (currentPage.value - 1) * perPage + 1;
  }

  int get paginationEnd {
    if (paginationFromApi.value > 0 && paginationToApi.value > 0) return paginationToApi.value;
    final perPage = entriesPerPage.value.clamp(1, UniversitiesInstitutesApi.maxPerPage);
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
              r.university.toLowerCase().contains(q) ||
              r.authority.toLowerCase().contains(q) ||
              r.bondPenalty.toLowerCase().contains(q) ||
              r.bedsCount.contains(q),
        ),
      );
    }
  }
}
