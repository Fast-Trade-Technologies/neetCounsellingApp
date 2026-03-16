import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../api_services/filters_api.dart';
import '../../../../api_services/competition_statistics_api.dart';

/// Past Years Competition screen. Uses GET /common/states for state filter dropdown.
/// Loads data from GET /5-year-competition API.
class CompetitionStatisticsController extends GetxController {
  final RxInt breakdownTabIndex = 0.obs;
  final RxString selectedYearNationality = '2025'.obs;
  final RxString selectedYearCategory = '2025'.obs;
  final RxString selectedYearGender = '2025'.obs;
  final RxString selectedState = 'All'.obs;
  final RxString selectedStateId = ''.obs;
  final RxString selectedYearState = '2025'.obs;
  /// 'registered' | 'appeared' | 'qualified' – drives state-wise map data
  final RxString selectedStateWiseDataType = 'registered'.obs;
  /// Search query for filtering state-wise competition list
  final RxString stateWiseSearchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  // Chart data from API
  final RxList<String> chartYears = <String>[].obs;
  final RxList<int> registeredData = <int>[].obs;
  final RxList<int> appearedData = <int>[].obs;
  final RxList<int> qualifiedData = <int>[].obs;
  
  // API response data
  final RxMap<String, dynamic> apiData = <String, dynamic>{}.obs;
  final RxMap<String, Map<String, dynamic>> nationalityByYear = <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, Map<String, dynamic>> genderByYear = <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, Map<String, dynamic>> categoryByYear = <String, Map<String, dynamic>>{}.obs;
  final RxMap<String, Map<String, dynamic>> dataByYear = <String, Map<String, dynamic>>{}.obs;
  
  // Type mappings
  final RxMap<String, String> candidatesTypes = <String, String>{}.obs;
  final RxMap<String, String> nationalityTypes = <String, String>{}.obs;
  final RxMap<String, String> genderTypes = <String, String>{}.obs;
  final RxMap<String, String> categoryTypes = <String, String>{}.obs;
  final RxMap<String, String> examTypes = <String, String>{}.obs;

  static const List<String> breakdownTabs = [
    'Candidates',
    'Nationality',
    'Gender',
    'Category',
    'Exam',
  ];
  static const List<String> years = ['2025', '2024', '2023', '2022', '2021', '2020', '2019'];
  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  List<String> get statesList => stateFilters.isEmpty
      ? ['All', 'Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka']
      : ['All', ...stateFilters.map((e) => e.name)];

  List<String> get yearsList => years;

  /// Pan/zoom for the state-wise SVG map (same as college_seats).
  final TransformationController mapTransformController = TransformationController();
  double _mapScale = 1.0;

  void resetMapView() {
    _mapScale = 1.0;
    mapTransformController.value = Matrix4.identity();
  }

  void zoomInMap() {
    _setMapScale(_mapScale * 1.2);
  }

  void zoomOutMap() {
    _setMapScale(_mapScale / 1.2);
  }

  void _setMapScale(double scale) {
    _mapScale = scale.clamp(0.8, 4.0);
    mapTransformController.value = Matrix4.identity()..scale(_mapScale);
  }

  @override
  void onInit() {
    super.onInit();
    _loadStateFilters();
    loadCompetitionData();
  }

  @override
  void onClose() {
    mapTransformController.dispose();
    super.onClose();
  }

  Future<void> _loadStateFilters() async {
    final (success, stateList, _) = await FiltersApi.getStates(showLoader: false);
    if (success && stateList.isNotEmpty) {
      stateFilters.assignAll(stateList);
      if (selectedStateId.value.isEmpty && stateList.isNotEmpty) {
        // Set default state to Uttar Pradesh
        final upState = stateList.where((e) => 
          e.name.toLowerCase().contains('uttar pradesh') || 
          e.name.toLowerCase().contains('up') ||
          e.name.toLowerCase() == 'up'
        ).toList();
        if (upState.isNotEmpty) {
          selectedState.value = upState.first.name;
          selectedStateId.value = upState.first.id;
        } else {
          selectedState.value = stateList.first.name;
          selectedStateId.value = stateList.first.id;
        }
      }
    }
  }

  Future<void> loadCompetitionData() async {
    error.value = '';
    isLoading.value = true;
    final stateId = selectedStateId.value.isNotEmpty 
        ? selectedStateId.value 
        : (stateFilters.isNotEmpty ? stateFilters.first.id : '0');
    final (success, data, errorMessage) = await CompetitionStatisticsApi.getCompetitionStatistics(
      stateId: stateId,
      year: selectedYearState.value,
      showLoader: false,
    );
    isLoading.value = false;
    
    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load competition statistics';
      // Keep using static data if API fails
      return;
    }
    
    // Store full API data (includes state_map_data for state-wise map: year -> registered/appeared/qualified -> state codes)
    apiData.value = Map<String, dynamic>.from(data);

    // Parse chart_data from API response
    final chartData = data['chart_data'];
    if (chartData is Map) {
      final chartMap = Map<String, dynamic>.from(chartData);
      
      // Parse years
      final yearsRaw = chartMap['years'];
      if (yearsRaw is List) {
        chartYears.assignAll(yearsRaw.map((e) => e?.toString() ?? '').where((e) => e.isNotEmpty).toList());
      }
      
      // Parse registered data
      final registeredRaw = chartMap['registered'];
      if (registeredRaw is List) {
        registeredData.assignAll(registeredRaw.map((e) => e is int ? e : int.tryParse(e?.toString() ?? '0') ?? 0).toList());
      }
      
      // Parse appeared data
      final appearedRaw = chartMap['appeared'];
      if (appearedRaw is List) {
        appearedData.assignAll(appearedRaw.map((e) => e is int ? e : int.tryParse(e?.toString() ?? '0') ?? 0).toList());
      }
      
      // Parse qualified data
      final qualifiedRaw = chartMap['qualified'];
      if (qualifiedRaw is List) {
        qualifiedData.assignAll(qualifiedRaw.map((e) => e is int ? e : int.tryParse(e?.toString() ?? '0') ?? 0).toList());
      }
    }
    
    // Parse type mappings
    _parseTypeMappings(data);
    
    // Parse nationality_by_year
    final nationalityRaw = data['nationality_by_year'];
    if (nationalityRaw is Map) {
      final map = Map<String, Map<String, dynamic>>.from(
        nationalityRaw.map((k, v) => MapEntry(
          k.toString(),
          v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{},
        )),
      );
      nationalityByYear.value = map;
    }
    
    // Parse gender_by_year
    final genderRaw = data['gender_by_year'];
    if (genderRaw is Map) {
      final map = Map<String, Map<String, dynamic>>.from(
        genderRaw.map((k, v) => MapEntry(
          k.toString(),
          v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{},
        )),
      );
      genderByYear.value = map;
    }
    
    // Parse category_by_year
    final categoryRaw = data['category_by_year'];
    if (categoryRaw is Map) {
      final map = Map<String, Map<String, dynamic>>.from(
        categoryRaw.map((k, v) => MapEntry(
          k.toString(),
          v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{},
        )),
      );
      categoryByYear.value = map;
    }
    
    // Parse data_by_year
    final dataByYearRaw = data['data_by_year'];
    if (dataByYearRaw is Map) {
      final map = Map<String, Map<String, dynamic>>.from(
        dataByYearRaw.map((k, v) => MapEntry(
          k.toString(),
          v is Map ? Map<String, dynamic>.from(v) : <String, dynamic>{},
        )),
      );
      dataByYear.value = map;
    }
  }
  
  void _parseTypeMappings(Map<String, dynamic> data) {
    // Parse candidates_types
    final candidatesTypesRaw = data['candidates_types'];
    if (candidatesTypesRaw is Map) {
      candidatesTypes.value = Map<String, String>.from(
        candidatesTypesRaw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
      );
    }
    
    // Parse nationality_types
    final nationalityTypesRaw = data['nationality_types'];
    if (nationalityTypesRaw is Map) {
      nationalityTypes.value = Map<String, String>.from(
        nationalityTypesRaw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
      );
    }
    
    // Parse gender_types
    final genderTypesRaw = data['gender_types'];
    if (genderTypesRaw is Map) {
      genderTypes.value = Map<String, String>.from(
        genderTypesRaw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
      );
    }
    
    // Parse category_types
    final categoryTypesRaw = data['category_types'];
    if (categoryTypesRaw is Map) {
      categoryTypes.value = Map<String, String>.from(
        categoryTypesRaw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
      );
    }
    
    // Parse exam_types
    final examTypesRaw = data['exam_types'];
    if (examTypesRaw is Map) {
      examTypes.value = Map<String, String>.from(
        examTypesRaw.map((k, v) => MapEntry(k.toString(), v?.toString() ?? '')),
      );
    }
  }
  
  /// First column header for the breakdown table based on selected tab.
  String get breakdownTableLabel {
    final index = breakdownTabIndex.value;
    if (index == 0) return 'Candidates';
    if (index == 1) return 'Nationality';
    if (index == 2) return 'Gender';
    if (index == 3) return 'Category';
    if (index == 4) return 'Exam';
    return 'Category';
  }

  // Getters for breakdown table data – content depends on selected tab
  List<Map<String, dynamic>> get breakdownRows {
    final index = breakdownTabIndex.value;
    if (index == 0) return _candidatesBreakdownRows;
    if (index == 1) return _nationalityBreakdownRows;
    if (index == 2) return _genderBreakdownRows;
    if (index == 3) return _categoryBreakdownRows;
    if (index == 4) return _examBreakdownRows;
    return _candidatesBreakdownRows;
  }

  List<Map<String, dynamic>> get _candidatesBreakdownRows {
    if (dataByYear.isEmpty) return _defaultBreakdownRows;
    final registeredLabel = candidatesTypes['registered'] ?? 'No. Of Candidates Registered';
    final presentLabel = candidatesTypes['present'] ?? 'No. Of Candidates Present';
    final absentLabel = candidatesTypes['absent'] ?? 'No. Of Candidates Absent';
    final registeredRow = <String, dynamic>{'label': registeredLabel};
    final presentRow = <String, dynamic>{'label': presentLabel};
    final absentRow = <String, dynamic>{'label': absentLabel};
    for (final year in breakdownYears) {
      final yearData = dataByYear[year];
      registeredRow[year] = yearData?['registered'] ?? 0;
      presentRow[year] = yearData?['present'] ?? 0;
      absentRow[year] = yearData?['absent'] ?? 0;
    }
    return [registeredRow, presentRow, absentRow];
  }

  List<Map<String, dynamic>> get _nationalityBreakdownRows {
    if (nationalityByYear.isEmpty) return _defaultNationalityBreakdownRows;
    final types = ['indian', 'nri', 'foreigeners', 'oci'];
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < types.length; i++) {
      final typeKey = types[i];
      final label = nationalityTypes[typeKey] ?? typeKey;
      final row = <String, dynamic>{'label': label};
      for (final year in breakdownYears) {
        final yearData = nationalityByYear[year];
        final reg = yearData?['reg'] as List? ?? [];
        row[year] = (i < reg.length) ? (reg[i] is int ? reg[i] as int : int.tryParse(reg[i].toString()) ?? 0) : 0;
      }
      rows.add(row);
    }
    return rows.isEmpty ? _defaultNationalityBreakdownRows : rows;
  }

  List<Map<String, dynamic>> get _genderBreakdownRows {
    if (genderByYear.isEmpty) return _defaultGenderBreakdownRows;
    final types = ['female', 'male', 'transgender'];
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < types.length; i++) {
      final typeKey = types[i];
      final label = genderTypes[typeKey] ?? typeKey;
      final row = <String, dynamic>{'label': label};
      for (final year in breakdownYears) {
        final yearData = genderByYear[year];
        final reg = yearData?['reg'] as List? ?? [];
        row[year] = (i < reg.length) ? (reg[i] is int ? reg[i] as int : int.tryParse(reg[i].toString()) ?? 0) : 0;
      }
      rows.add(row);
    }
    return rows.isEmpty ? _defaultGenderBreakdownRows : rows;
  }

  List<Map<String, dynamic>> get _categoryBreakdownRows {
    if (categoryByYear.isEmpty) return _defaultCategoryBreakdownRows;
    final types = ['obc', 'un_reserved', 'sc', 'st', 'ews'];
    final rows = <Map<String, dynamic>>[];
    for (var i = 0; i < types.length; i++) {
      final typeKey = types[i];
      final label = categoryTypes[typeKey] ?? typeKey;
      final row = <String, dynamic>{'label': label};
      for (final year in breakdownYears) {
        final yearData = categoryByYear[year];
        final reg = yearData?['reg'] as List? ?? [];
        row[year] = (i < reg.length) ? (reg[i] is int ? reg[i] as int : int.tryParse(reg[i].toString()) ?? 0) : 0;
      }
      rows.add(row);
    }
    return rows.isEmpty ? _defaultCategoryBreakdownRows : rows;
  }

  List<Map<String, dynamic>> get _examBreakdownRows {
    if (dataByYear.isEmpty) return _defaultExamBreakdownRows;
    final examKeys = ['no_of_centers', 'no_of_cities', 'no_of_invigilators', 'no_f_center_deputy', 'not_of_observers', 'no_of_city_coordinators', 'no_of_languages', 'pio'];
    final rows = <Map<String, dynamic>>[];
    for (final key in examKeys) {
      final label = examTypes[key] ?? key;
      final row = <String, dynamic>{'label': label};
      for (final year in breakdownYears) {
        final yearData = dataByYear[year];
        final v = yearData?[key];
        row[year] = v is int ? v : (v != null ? int.tryParse(v.toString()) ?? 0 : 0);
      }
      rows.add(row);
    }
    return rows.isEmpty ? _defaultExamBreakdownRows : rows;
  }
  
  // Get nationality data for selected year
  List<Map<String, dynamic>> getNationalityData(String year) {
    final yearData = nationalityByYear[year];
    if (yearData == null) return _defaultNationalityData;
    
    final data = <Map<String, dynamic>>[];
    final reg = yearData['reg'] as List? ?? [];
    final app = yearData['app'] as List? ?? [];
    final qual = yearData['qual'] as List? ?? [];
    
    final types = ['indian', 'nri', 'foreigeners', 'oci'];
    for (int i = 0; i < types.length; i++) {
      if (i < reg.length) {
        final typeKey = types[i];
        final label = nationalityTypes[typeKey] ?? typeKey;
        data.add({
          'label': label,
          'registered': (reg[i] is int ? reg[i] : int.tryParse(reg[i]?.toString() ?? '0') ?? 0) / 100000.0,
          'appeared': (app.length > i ? (app[i] is int ? app[i] : int.tryParse(app[i]?.toString() ?? '0') ?? 0) : 0) / 100000.0,
          'qualified': (qual.length > i ? (qual[i] is int ? qual[i] : int.tryParse(qual[i]?.toString() ?? '0') ?? 0) : 0) / 100000.0,
        });
      }
    }
    
    return data.isEmpty ? _defaultNationalityData : data;
  }
  
  // Get gender data for selected year
  List<Map<String, dynamic>> getGenderData(String year) {
    final yearData = genderByYear[year];
    if (yearData == null) return _defaultGenderData;
    
    final data = <Map<String, dynamic>>[];
    final reg = yearData['reg'] as List? ?? [];
    final app = yearData['app'] as List? ?? [];
    final qual = yearData['qual'] as List? ?? [];
    
    final types = ['female', 'male', 'transgender'];
    for (int i = 0; i < types.length; i++) {
      if (i < reg.length) {
        final typeKey = types[i];
        final label = genderTypes[typeKey] ?? typeKey;
        data.add({
          'label': label,
          'registered': (reg[i] is int ? reg[i] : int.tryParse(reg[i]?.toString() ?? '0') ?? 0) / 100000.0,
          'appeared': (app.length > i ? (app[i] is int ? app[i] : int.tryParse(app[i]?.toString() ?? '0') ?? 0) : 0) / 100000.0,
          'qualified': (qual.length > i ? (qual[i] is int ? qual[i] : int.tryParse(qual[i]?.toString() ?? '0') ?? 0) : 0) / 100000.0,
        });
      }
    }
    
    return data.isEmpty ? _defaultGenderData : data;
  }
  
  // Get category data for selected year
  List<Map<String, dynamic>> getCategoryData(String year) {
    final yearData = categoryByYear[year];
    if (yearData == null) return _defaultCategoryData;
    
    final data = <Map<String, dynamic>>[];
    final reg = yearData['reg'] as List? ?? [];
    final app = yearData['app'] as List? ?? [];
    final qual = yearData['qual'] as List? ?? [];
    
    final types = ['obc', 'un_reserved', 'sc', 'st', 'ews'];
    for (int i = 0; i < types.length; i++) {
      if (i < reg.length && reg[i] > 0) {
        final typeKey = types[i];
        final label = categoryTypes[typeKey] ?? typeKey;
        data.add({
          'label': label,
          'registered': (reg[i] is int ? reg[i] : int.tryParse(reg[i]?.toString() ?? '0') ?? 0) / 100000.0,
          'appeared': (app.length > i ? (app[i] is int ? app[i] : int.tryParse(app[i]?.toString() ?? '0') ?? 0) : 0) / 100000.0,
          'qualified': (qual.length > i ? (qual[i] is int ? qual[i] : int.tryParse(qual[i]?.toString() ?? '0') ?? 0) : 0) / 100000.0,
        });
      }
    }
    
    return data.isEmpty ? _defaultCategoryData : data;
  }
  
  // Get yearly insights from chart_data
  List<Map<String, dynamic>> get yearlyInsights {
    if (chartYears.isEmpty || registeredData.isEmpty) {
      return _defaultYearlyInsights;
    }
    
    final insights = <Map<String, dynamic>>[];
    for (int i = 0; i < chartYears.length; i++) {
      insights.add({
        'year': chartYears[i],
        'registered': registeredData.length > i ? registeredData[i] / 100000.0 : 0.0,
        'appeared': appearedData.length > i ? appearedData[i] / 100000.0 : 0.0,
        'qualified': qualifiedData.length > i ? qualifiedData[i] / 100000.0 : 0.0,
      });
    }
    
    return insights.isEmpty ? _defaultYearlyInsights : insights;
  }

  @override
  Future<void> refresh() async {
    await _loadStateFilters();
    await loadCompetitionData();
  }

  void setBreakdownTab(int index) => breakdownTabIndex.value = index;
  void setYearNationality(String v) => selectedYearNationality.value = v;
  void setYearCategory(String v) => selectedYearCategory.value = v;
  void setYearGender(String v) => selectedYearGender.value = v;
  void setState(String v) {
    selectedState.value = v;
    if (v == 'All') {
      selectedStateId.value = '';
    } else {
      final match = stateFilters.where((e) => e.name == v).toList();
      selectedStateId.value = match.isEmpty ? '' : match.first.id;
    }
    loadCompetitionData();
  }
  void setYearState(String v) {
    selectedYearState.value = v;
    loadCompetitionData();
  }
  void setStateWiseDataType(String v) => selectedStateWiseDataType.value = v;
  void setStateWiseSearchQuery(String v) => stateWiseSearchQuery.value = v;

  /// API state code (e.g. in-ap) to SVG id (e.g. INAP) for india_states.svg
  static String _stateMapCodeToSvgId(String code) {
    final lower = code.toLowerCase();
    if (lower == 'in-cg') return 'INCT';
    if (lower == 'in-dnhdd') return 'INDH';
    if (lower == 'in-ladakh') return 'INLA';
    return code.toUpperCase().replaceAll('-', '');
  }

  /// Map of SVG id -> value for the state-wise map. Uses selected year + selected chip (Registered / Appeared / Qualified).
  /// Data from same API: apiData['state_map_data'][year][dataType] e.g. state_map_data["2024"]["registered"].
  Map<String, int> get stateWiseMapValuesBySvgId {
    final year = selectedYearState.value;
    final dataType = selectedStateWiseDataType.value; // 'registered' | 'appeared' | 'qualified'
    Map<String, dynamic>? yearData;
    final stateMapData = apiData['state_map_data'];
    if (stateMapData is Map && stateMapData[year] is Map) {
      yearData = Map<String, dynamic>.from(stateMapData[year] as Map);
    }
    if (yearData == null) {
      for (final key in ['state_wise', 'state_wise_by_year', 'year_wise_state_data']) {
        final top = apiData[key];
        if (top is Map && top[year] is Map) {
          yearData = Map<String, dynamic>.from(top[year] as Map);
          break;
        }
      }
    }
    if (yearData == null && apiData[year] is Map) {
      yearData = Map<String, dynamic>.from(apiData[year] as Map);
    }
    if (yearData == null) return {};
    final typeData = yearData[dataType];
    if (typeData is! Map) return {};
    final result = <String, int>{};
    for (final entry in typeData.entries) {
      final svgId = _stateMapCodeToSvgId(entry.key.toString());
      final v = entry.value;
      result[svgId] = v is int ? v : int.tryParse(v.toString()) ?? 0;
    }
    return result;
  }

  /// State name -> API code (e.g. Andhra Pradesh -> in-ap) for map highlight
  static const Map<String, String> _stateNameToCode = {
    'Uttar Pradesh': 'in-up',
    'Maharashtra': 'in-mh',
    'Rajasthan': 'in-rj',
    'Karnataka': 'in-ka',
    'Tamil Nadu': 'in-tn',
    'Gujarat': 'in-gj',
    'West Bengal': 'in-wb',
    'Madhya Pradesh': 'in-mp',
    'Bihar': 'in-br',
    'Andhra Pradesh': 'in-ap',
    'Telangana': 'in-tg',
    'Kerala': 'in-kl',
    'Odisha': 'in-or',
    'Punjab': 'in-pb',
    'Haryana': 'in-hr',
    'Jharkhand': 'in-jh',
    'Chandigarh': 'in-ch',
    'Delhi': 'in-dl',
    'Himachal Pradesh': 'in-hp',
    'Uttarakhand': 'in-ut',
    'Jammu & Kashmir': 'in-jk',
    'Assam': 'in-as',
    'Andaman & Nicobar': 'in-an',
    'Arunachal Pradesh': 'in-ar',
    'Manipur': 'in-mn',
    'Meghalaya': 'in-ml',
    'Mizoram': 'in-mz',
    'Nagaland': 'in-nl',
    'Sikkim': 'in-sk',
    'Tripura': 'in-tr',
    'Goa': 'in-ga',
    'Puducherry': 'in-py',
    'Ladakh': 'in-ladakh',
    'Dadra & Nagar Haveli': 'in-dnhdd',
    'Dadra & Nagar Haveli and Daman and Diu': 'in-dnhdd',
    'Lakshadweep': 'in-ld',
    'Chhattisgarh': 'in-cg',
  };

  /// API code for the currently selected state (for map highlight). Null if All.
  String? get selectedStateCodeForMap {
    final name = selectedState.value;
    if (name.isEmpty || name == 'All') return null;
    final code = _stateNameToCode[name];
    if (code != null) return code;
    // Match by case-insensitive or partial name
    for (final e in _stateNameToCode.entries) {
      if (e.key.toLowerCase() == name.toLowerCase()) return e.value;
    }
    return null;
  }

  // Sample: row label, then per year (2019..2025): value, trend up/down, change
  static const List<Map<String, dynamic>> _defaultBreakdownRows = [
    {
      'label': 'No. Of Candidates Registered',
      '2019': 1519375,
      '2020': 1597435,
      '2021': 1617557,
      '2022': 1873894,
      '2023': 2066389,
      '2024': 2406982,
      '2025': 2276069,
    },
    {
      'label': 'No. Of Candidates Present',
      '2019': 1417893,
      '2020': 1476651,
      '2021': 1550000,
      '2022': 1760000,
      '2023': 1950000,
      '2024': 2200000,
      '2025': 2209318,
    },
    {
      'label': 'No. Of Candidates Absent',
      '2019': 101482,
      '2020': 120784,
      '2021': 67557,
      '2022': 113894,
      '2023': 116389,
      '2024': 206982,
      '2025': 66751,
    },
  ];

  static const List<String> breakdownYears = ['2019', '2020', '2021', '2022', '2023', '2024', '2025'];

  static const List<Map<String, dynamic>> _defaultNationalityBreakdownRows = [
    {'label': 'Indian Nationals', '2019': 1516066, '2020': 1593907, '2021': 1612276, '2022': 1870015, '2023': 2036316, '2024': 2402774, '2025': 2273528},
    {'label': 'NRIs', '2019': 1884, '2020': 1869, '2021': 1054, '2022': 910, '2023': 852, '2024': 1304, '2025': 741},
    {'label': 'Foreigners', '2019': 687, '2020': 878, '2021': 883, '2022': 771, '2023': 789, '2024': 1196, '2025': 939},
    {'label': 'OCIs', '2019': 675, '2020': 732, '2021': 564, '2022': 647, '2023': 642, '2024': 805, '2025': 861},
  ];
  static const List<Map<String, dynamic>> _defaultGenderBreakdownRows = [
    {'label': 'Female', '2019': 838955, '2020': 880843, '2021': 903782, '2022': 1064794, '2023': 1184513, '2024': 1376863, '2025': 1310062},
    {'label': 'Male', '2019': 680414, '2020': 716586, '2021': 710979, '2022': 807538, '2023': 902936, '2024': 1029198, '2025': 965996},
    {'label': 'Transgender', '2019': 6, '2020': 5, '2021': 16, '2022': 11, '2023': 13, '2024': 18, '2025': 11},
  ];
  static const List<Map<String, dynamic>> _defaultCategoryBreakdownRows = [
    {'label': 'OBC', '2019': 677544, '2020': 706214, '2021': 693879, '2022': 791135, '2023': 890150, '2024': 1054277, '2025': 948507},
    {'label': 'Un-Reserved', '2019': 534072, '2020': 475534, '2021': 460159, '2022': 565964, '2023': 607131, '2024': 647260, '2025': 689366},
    {'label': 'SC', '2019': 211303, '2020': 221253, '2021': 235696, '2022': 268750, '2023': 303318, '2024': 356727, '2025': 333646},
    {'label': 'ST', '2019': 96454, '2020': 100519, '2021': 100904, '2022': 113830, '2023': 132490, '2024': 157115, '2025': 150224},
    {'label': 'EWS', '2019': 0, '2020': 93915, '2021': 124139, '2022': 132664, '2023': 154373, '2024': 190700, '2025': 154326},
  ];
  static const List<Map<String, dynamic>> _defaultExamBreakdownRows = [
    {'label': 'No of Centers', '2019': 2546, '2020': 3862, '2021': 3858, '2022': 3570, '2023': 4097, '2024': 4750, '2025': 5468},
    {'label': 'No of Cities', '2019': 154, '2020': 155, '2021': 202, '2022': 497, '2023': 499, '2024': 571, '2025': 566},
  ];

  // Yearly insights: year -> registered, appeared, qualified (in lakhs)
  static const List<Map<String, dynamic>> _defaultYearlyInsights = [
    {'year': '2019', 'registered': 15.2, 'appeared': 14.2, 'qualified': 7.9},
    {'year': '2020', 'registered': 16.0, 'appeared': 14.8, 'qualified': 8.6},
    {'year': '2021', 'registered': 16.2, 'appeared': 15.5, 'qualified': 8.9},
    {'year': '2022', 'registered': 18.7, 'appeared': 17.6, 'qualified': 9.9},
    {'year': '2023', 'registered': 20.7, 'appeared': 19.5, 'qualified': 11.2},
    {'year': '2024', 'registered': 24.1, 'appeared': 22.0, 'qualified': 12.1},
    {'year': '2025', 'registered': 22.8, 'appeared': 22.1, 'qualified': 12.4},
  ];

  // Nationality: label, registered, appeared, qualified (in lakhs)
  static const List<Map<String, dynamic>> _defaultNationalityData = [
    {'label': 'Indian', 'registered': 22.1, 'appeared': 21.5, 'qualified': 12.0},
    {'label': 'NRI', 'registered': 0.45, 'appeared': 0.42, 'qualified': 0.28},
    {'label': 'OCI', 'registered': 0.25, 'appeared': 0.22, 'qualified': 0.12},
  ];

  // Category: label, registered (lakhs), qualified (lakhs)
  static const List<Map<String, dynamic>> _defaultCategoryData = [
    {'label': 'General', 'registered': 10.2, 'qualified': 4.8},
    {'label': 'OBC', 'registered': 6.1, 'qualified': 3.2},
    {'label': 'EWS', 'registered': 2.4, 'qualified': 1.1},
    {'label': 'SC', 'registered': 2.8, 'qualified': 1.8},
    {'label': 'ST', 'registered': 1.3, 'qualified': 0.5},
  ];

  // Gender: label, count (lakhs)
  static const List<Map<String, dynamic>> _defaultGenderData = [
    {'label': 'Female', 'value': 12.8},
    {'label': 'Male', 'value': 9.3},
  ];

  // State-wise: label, registered (lakhs)
  static const List<Map<String, dynamic>> stateWiseData = [
    {'label': 'UP', 'registered': 3.2, 'appeared': 3.0, 'qualified': 1.6},
    {'label': 'Maharashtra', 'registered': 2.8, 'appeared': 2.7, 'qualified': 1.4},
    {'label': 'Rajasthan', 'registered': 2.1, 'appeared': 2.0, 'qualified': 1.0},
    {'label': 'Karnataka', 'registered': 1.8, 'appeared': 1.7, 'qualified': 0.9},
    {'label': 'Others', 'registered': 12.9, 'appeared': 12.7, 'qualified': 7.5},
  ];
}
