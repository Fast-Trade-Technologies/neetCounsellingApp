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

  @override
  void onInit() {
    super.onInit();
    _loadStateFilters();
    loadCompetitionData();
  }

  Future<void> _loadStateFilters() async {
    final (success, stateList, _) = await FiltersApi.getStates(showLoader: false);
    if (success && stateList.isNotEmpty) {
      stateFilters.assignAll(stateList);
      if (selectedStateId.value.isEmpty && stateList.isNotEmpty) {
        selectedState.value = stateList.first.name;
        selectedStateId.value = stateList.first.id;
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
    
    // Store full API data
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
  
  // Getters for breakdown table data
  List<Map<String, dynamic>> get breakdownRows {
    if (dataByYear.isEmpty) return _defaultBreakdownRows;
    
    final rows = <Map<String, dynamic>>[];
    final registeredLabel = candidatesTypes['registered'] ?? 'No. Of Candidates Registered';
    final presentLabel = candidatesTypes['present'] ?? 'No. Of Candidates Present';
    final absentLabel = candidatesTypes['absent'] ?? 'No. Of Candidates Absent';
    
    // Registered row
    final registeredRow = <String, dynamic>{'label': registeredLabel};
    for (final year in breakdownYears) {
      final yearData = dataByYear[year];
      registeredRow[year] = yearData?['registered'] ?? 0;
    }
    rows.add(registeredRow);
    
    // Present row
    final presentRow = <String, dynamic>{'label': presentLabel};
    for (final year in breakdownYears) {
      final yearData = dataByYear[year];
      presentRow[year] = yearData?['present'] ?? 0;
    }
    rows.add(presentRow);
    
    // Absent row
    final absentRow = <String, dynamic>{'label': absentLabel};
    for (final year in breakdownYears) {
      final yearData = dataByYear[year];
      absentRow[year] = yearData?['absent'] ?? 0;
    }
    rows.add(absentRow);
    
    return rows;
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
