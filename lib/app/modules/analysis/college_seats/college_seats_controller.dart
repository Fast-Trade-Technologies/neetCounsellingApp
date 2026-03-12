import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api_services/dashboard_api.dart';

class CollegeSeatsController extends GetxController {
  final RxInt selectedTab = 0.obs; // 0 = Seat Wise, 1 = College Wise

  /// Controls pan/zoom for the SVG map (kept for future use).
  final TransformationController mapTransformController = TransformationController();
  double _currentScale = 1.0;

  /// State code (e.g. in-up) -> seat count. Fetched from dashboard/fetch-data API.
  final RxMap<String, int> _stateSeatByCode = <String, int>{}.obs;

  final RxBool mapDataLoading = false.obs;
  final RxString mapDataError = ''.obs;

  /// Counselling type and course type for fetch_map_data API (defaults 1).
  String get counsellingTypeId => _counsellingTypeId;
  String _counsellingTypeId = '1';
  String get courseTypeId => _courseTypeId;
  String _courseTypeId = '1';

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
    loadMapData();
  }

  Future<void> loadMapData() async {
    mapDataError.value = '';
    mapDataLoading.value = true;
    final (success, map, errorMessage) = await DashboardApi.fetchMapData(
      counsellingTypeId: _counsellingTypeId,
      courseTypeId: _courseTypeId,
      showLoader: false,
    );
    mapDataLoading.value = false;
    if (success && map.isNotEmpty) {
      _stateSeatByCode.assignAll(map);
      _setDefaultSelectedState();
    } else {
      mapDataError.value = errorMessage ?? 'Failed to load map data';
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

  void setFilters({String? counsellingTypeId, String? courseTypeId}) {
    if (counsellingTypeId != null) _counsellingTypeId = counsellingTypeId;
    if (courseTypeId != null) _courseTypeId = courseTypeId;
    loadMapData();
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
