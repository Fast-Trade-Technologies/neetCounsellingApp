import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api_services/dashboard_api.dart';
import '../../../../api_services/filters_api.dart';

class InstituteSummary {
  InstituteSummary({
    required this.instituteTypeId,
    required this.instituteName,
    required this.colleges,
    required this.seats,
  });

  final int instituteTypeId;
  final String instituteName;
  final int colleges;
  final int seats;
}

class CollegeInfo {
  CollegeInfo({
    required this.id,
    required this.name,
    required this.totalSeats,
    required this.type,
    required this.website,
  });

  final String id;
  final String name;
  final int totalSeats;
  final String type;
  final String website;
}

class CollegeSeatsController extends GetxController {
  final RxInt selectedTab = 0.obs; // 0 = Seat Wise, 1 = College Wise

  /// Controls pan/zoom for the SVG map (kept for future use).
  final TransformationController mapTransformController = TransformationController();
  double _currentScale = 1.0;

  /// State code (e.g. in-up) -> count from map_data (college wise).
  final RxMap<String, int> _stateSeatByCode = <String, int>{}.obs;

  final RxBool mapDataLoading = false.obs;
  final RxString mapDataError = ''.obs;
  final RxBool filtersLoading = false.obs;

  /// Totals and breakdown from college_wise API.
  final RxInt totalColleges = 0.obs;
  final RxInt totalSeats = 0.obs;
  final RxList<InstituteSummary> instituteData = <InstituteSummary>[].obs;
  final RxList<CollegeInfo> collegeList = <CollegeInfo>[].obs;
  final RxString collegeSearchQuery = ''.obs;
  final RxInt _collegeVisibleCount = 30.obs;

  /// Counselling type for fetch_map_data API (defaults 1).
  String get counsellingTypeId => _counsellingTypeId;
  String _counsellingTypeId = '1';
  final RxList<FilterItem> counsellingTypes = <FilterItem>[].obs;
  final RxString selectedCounsellingTypeName = ''.obs;
  final RxString selectedCounsellingTypeId = ''.obs;

  /// Currently selected state (human readable).
  final RxString _selectedStateName = ''.obs;

  /// Exposed getters used by the view.
  List<String> get stateNames {
    final names = _stateSeatByCode.keys.map(_stateNameFromCode).toList();
    names.sort();
    return names;
  }

  String get selectedStateName => _selectedStateName.value;

  int get selectedStateSeats {
    if (_selectedStateName.value.isEmpty) return 0;
    String? codeMatch;
    for (final code in _stateSeatByCode.keys) {
      if (_stateNameFromCode(code) == _selectedStateName.value) {
        codeMatch = code;
        break;
      }
    }
    if (codeMatch == null) return 0;
    return _stateSeatByCode[codeMatch] ?? 0;
  }

  /// SVG state code (e.g. 'in-up') for the currently selected state,
  /// used to highlight the state path in the India map.
  String? get selectedStateCode {
    if (_selectedStateName.value.isEmpty) return null;
    for (final code in _stateSeatByCode.keys) {
      if (_stateNameFromCode(code) == _selectedStateName.value) return code;
    }
    return null;
  }

  @override
  void onReady() {
    super.onReady();
    _initFiltersAndData();
  }

  Future<void> _initFiltersAndData() async {
    await _loadCounsellingTypes();
    await loadMapData();
  }

  Future<void> _loadCounsellingTypes() async {
    filtersLoading.value = true;
    final (success, list, errorMessage) = await FiltersApi.getCounsellingTypes(showLoader: false);
    filtersLoading.value = false;
    if (!success || list.isEmpty) {
      // Keep default counsellingTypeId = '1' if API fails.
      mapDataError.value = errorMessage ?? 'Failed to load counselling types';
      return;
    }
    counsellingTypes.assignAll(list);
    if (selectedCounsellingTypeId.value.isEmpty) {
      selectedCounsellingTypeId.value = list.first.id;
      selectedCounsellingTypeName.value = list.first.name;
      _counsellingTypeId = selectedCounsellingTypeId.value;
    }
  }

  Future<void> loadMapData() async {
    mapDataError.value = '';
    mapDataLoading.value = true;
    final (success, data, errorMessage) = await DashboardApi.fetchCollegeWiseData(
      counsellingTypeId: _counsellingTypeId,
      showLoader: false,
    );
    mapDataLoading.value = false;
    if (!success || data == null) {
      mapDataError.value = errorMessage ?? 'Failed to load map data';
      return;
    }

    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

    // Parse map_data for state-wise counts.
    final stateMap = <String, int>{};
    final mapData = data['map_data'];
    if (mapData is Map) {
      for (final e in mapData.entries) {
        final key = e.key.toString().trim().toLowerCase();
        if (key.isEmpty) continue;
        stateMap[key] = toInt(e.value);
      }
    }
    _stateSeatByCode.assignAll(stateMap);

    // Totals.
    totalColleges.value = toInt(data['total_colleges']);
    totalSeats.value = toInt(data['total_seats']);

    // Institute breakdown.
    final institutesRaw = data['institute_data'];
    final parsedInstitutes = <InstituteSummary>[];
    if (institutesRaw is List) {
      for (final e in institutesRaw) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        parsedInstitutes.add(
          InstituteSummary(
            instituteTypeId: toInt(m['institute_type_id']),
            instituteName: (m['institute_name'] ?? '').toString().trim(),
            colleges: toInt(m['colleges']),
            seats: toInt(m['seats']),
          ),
        );
      }
    }
    instituteData.assignAll(parsedInstitutes);

    // College list.
    final collegesRaw = data['college_list'];
    final parsedColleges = <CollegeInfo>[];
    if (collegesRaw is List) {
      for (final e in collegesRaw) {
        if (e is! Map) continue;
        final m = Map<String, dynamic>.from(e);
        parsedColleges.add(
          CollegeInfo(
            id: (m['id'] ?? '').toString(),
            name: (m['name'] ?? '').toString().trim(),
            totalSeats: toInt(m['total_seats']),
            type: (m['type'] ?? '').toString().trim(),
            website: (m['website'] ?? '').toString().trim(),
          ),
        );
      }
    }
    collegeList.assignAll(parsedColleges);
    _collegeVisibleCount.value = 30;

    _setDefaultSelectedState();
  }

  void _setDefaultSelectedState() {
    final names = stateNames;
    if (names.isEmpty) return;
    if (names.any((e) => e.toLowerCase().contains('uttar pradesh'))) {
      _selectedStateName.value =
          names.firstWhere((e) => e.toLowerCase().contains('uttar pradesh'));
    } else {
      _selectedStateName.value = names.first;
    }
  }

  void setFilters({String? counsellingTypeId}) {
    if (counsellingTypeId != null) _counsellingTypeId = counsellingTypeId;
    loadMapData();
  }

  void setCounsellingType(String name) {
    selectedCounsellingTypeName.value = name;
    final match = counsellingTypes.where((e) => e.name == name).toList();
    if (match.isNotEmpty) {
      selectedCounsellingTypeId.value = match.first.id;
      _counsellingTypeId = selectedCounsellingTypeId.value;
    }
    loadMapData();
  }

  List<CollegeInfo> get filteredColleges {
    final q = collegeSearchQuery.value.trim().toLowerCase();
    final base = q.isEmpty
        ? collegeList.toList()
        : collegeList.where((c) => c.name.toLowerCase().contains(q)).toList();

    if (q.isNotEmpty) {
      // Search ke time full filtered list dikhao (count usually kam hota hai).
      return base;
    }

    final limit = _collegeVisibleCount.value;
    if (base.length <= limit) return base;
    return base.take(limit).toList();
  }

  void setCollegeSearchQuery(String value) {
    collegeSearchQuery.value = value;
    _collegeVisibleCount.value = 30;
  }

  void loadMoreColleges() {
    _collegeVisibleCount.value += 30;
  }

  @override
  Future<void> refresh() async {
    await loadMapData();
  }

  void setTab(int index) => selectedTab.value = index;

  void setSelectedState(String stateName) {
    _selectedStateName.value = stateName;
  }

  void resetMapView() {
    _currentScale = 1.0;
    mapTransformController.value = Matrix4.identity();
  }

  void zoomIn() {
    _setScale(_currentScale * 1.2);
  }

  void zoomOut() {
    _setScale(_currentScale / 1.2);
  }

  void _setScale(double scale) {
    final clamped = scale.clamp(0.8, 4.0);
    _currentScale = clamped;
    mapTransformController.value = Matrix4.identity()..scale(_currentScale);
  }

  @override
  void onClose() {
    mapTransformController.dispose();
    super.onClose();
  }

  String _stateNameFromCode(String code) {
    const stateMap = {
      'in-up': 'Uttar Pradesh',
      'in-mh': 'Maharashtra',
      'in-rj': 'Rajasthan',
      'in-ka': 'Karnataka',
      'in-tn': 'Tamil Nadu',
      'in-gj': 'Gujarat',
      'in-wb': 'West Bengal',
      'in-mp': 'Madhya Pradesh',
      'in-br': 'Bihar',
      'in-ap': 'Andhra Pradesh',
      'in-tg': 'Telangana',
      'in-kl': 'Kerala',
      'in-or': 'Odisha',
      'in-pb': 'Punjab',
      'in-hr': 'Haryana',
      'in-jh': 'Jharkhand',
      'in-ch': 'Chandigarh',
      'in-dl': 'Delhi',
      'in-hp': 'Himachal Pradesh',
      'in-ut': 'Uttarakhand',
      'in-jk': 'Jammu & Kashmir',
      'in-as': 'Assam',
      'in-an': 'Andaman & Nicobar',
      'in-ar': 'Arunachal Pradesh',
      'in-mn': 'Manipur',
      'in-ml': 'Meghalaya',
      'in-mz': 'Mizoram',
      'in-nl': 'Nagaland',
      'in-sk': 'Sikkim',
      'in-tr': 'Tripura',
      'in-ga': 'Goa',
      'in-py': 'Puducherry',
      'in-dnhdd': 'Dadra & Nagar Haveli',
      'in-cg': 'Chhattisgarh',
    };
    return stateMap[code.toLowerCase()] ?? code.toUpperCase();
  }
}
