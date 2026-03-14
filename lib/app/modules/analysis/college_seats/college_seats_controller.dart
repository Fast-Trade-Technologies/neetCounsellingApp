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

  /// State code (e.g. in-up) -> count from map_data (seat wise: total_seats).
  final RxMap<String, int> _seatWiseStateByCode = <String, int>{}.obs;

  /// State code (e.g. in-up) -> count from map_data (college wise: number of colleges).
  final RxMap<String, int> _collegeWiseStateByCode = <String, int>{}.obs;

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
    final allCodes = <String>{}
      ..addAll(_seatWiseStateByCode.keys)
      ..addAll(_collegeWiseStateByCode.keys);
    final names = allCodes.map(_stateNameFromCode).toList();
    names.sort();
    return names;
  }

  String get selectedStateName => _selectedStateName.value;

  int get selectedStateSeats {
    if (_selectedStateName.value.isEmpty) return 0;
    String? codeMatch;
    final sourceMap =
        selectedTab.value == 0 ? _seatWiseStateByCode : _collegeWiseStateByCode;
    for (final code in sourceMap.keys) {
      if (_stateNameFromCode(code) == _selectedStateName.value) {
        codeMatch = code;
        break;
      }
    }
    if (codeMatch == null) return 0;
    return sourceMap[codeMatch] ?? 0;
  }

  /// SVG state code (e.g. 'in-up') for the currently selected state,
  /// used to highlight the state path in the India map.
  String? get selectedStateCode {
    if (_selectedStateName.value.isEmpty) return null;
    final sourceMap =
        selectedTab.value == 0 ? _seatWiseStateByCode : _collegeWiseStateByCode;
    for (final code in sourceMap.keys) {
      if (_stateNameFromCode(code) == _selectedStateName.value) return code;
    }
    return null;
  }

  /// Helper map for SVG placeholders: converts API keys like 'in-up'
  /// to SVG ids like 'INUP' so that `{{INUP}}` can be replaced in the SVG.
  Map<String, int> get stateSeatsBySvgId {
    final result = <String, int>{};
    final sourceMap =
        selectedTab.value == 0 ? _seatWiseStateByCode : _collegeWiseStateByCode;
    for (final entry in sourceMap.entries) {
      final svgId = entry.key.toUpperCase().replaceAll('-', '');
      result[svgId] = entry.value;
    }
    return result;
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
    try {
      int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;

      // 1) Default: seat_wise (metric=seat_wise). Map shows state-wise seat counts.
      final (seatSuccess, seatData, seatError) = await DashboardApi.fetchMapDataWithMetric(
        counsellingTypeId: _counsellingTypeId,
        metric: 'seat_wise',
        showLoader: false,
      );
      if (seatSuccess && seatData != null) {
        final seatMap = <String, int>{};
        final mapData = seatData['map_data'];
        if (mapData is Map) {
          for (final e in mapData.entries) {
            final key = e.key.toString().trim().toLowerCase();
            if (key.isEmpty) continue;
            seatMap[key] = toInt(e.value);
          }
        }
        _seatWiseStateByCode.assignAll(seatMap);
      } else {
        mapDataError.value = seatError ?? 'Failed to load seat-wise data';
      }

      // 2) College-wise (metric=college_wise). Map shows state-wise college counts; also has totals, institute_data, college_list.
      final (collegeSuccess, data, collegeError) = await DashboardApi.fetchMapDataWithMetric(
        counsellingTypeId: _counsellingTypeId,
        metric: 'college_wise',
        showLoader: false,
      );
      if (!collegeSuccess || data == null) {
        if (mapDataError.value.isEmpty) {
          mapDataError.value = collegeError ?? 'Failed to load college-wise data';
        }
        return;
      }

      // Parse map_data for college-wise state counts.
      final collegeMap = <String, int>{};
      final mapData = data['map_data'];
      if (mapData is Map) {
        for (final e in mapData.entries) {
          final key = e.key.toString().trim().toLowerCase();
          if (key.isEmpty) continue;
          collegeMap[key] = toInt(e.value);
        }
      }
      _collegeWiseStateByCode.assignAll(collegeMap);

      // Totals and lists from college_wise response.
      totalColleges.value = toInt(data['total_colleges']);
      totalSeats.value = toInt(data['total_seats']);

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
    } finally {
      mapDataLoading.value = false;
    }
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

  void setTab(int index) {
    if (selectedTab.value == index) return;
    selectedTab.value = index;
    // When toggling between Seat Wise / College Wise, we keep the same
    // selected state but the active map data (seat-wise vs college-wise)
    // for the SVG changes via [stateSeatsBySvgId]. No extra API call
    // is needed here because both maps are loaded in [loadMapData].
  }

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
