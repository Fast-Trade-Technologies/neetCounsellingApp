import 'package:get/get.dart';

import '../../../../api_services/counselling_api.dart';
import '../../../../api_services/filters_api.dart';

class CounsellingRow {
  CounsellingRow({
    required this.id,
    required this.name,
    required this.state,
    required this.stateType,
    required this.counsellingType,
    this.officialWebsiteUrl,
    this.registrationUrl,
    this.prospectsUrl,
    this.round,
    this.startDate,
    this.endDate,
    this.sNo,
  });

  final int id;
  final String name;
  final String state;
  final String stateType;
  final String counsellingType;
  final String? officialWebsiteUrl;
  final String? registrationUrl;
  final String? prospectsUrl;
  final String? round;
  final String? startDate;
  final String? endDate;
  final int? sNo; // For display purposes

  factory CounsellingRow.fromJson(Map<String, dynamic> json, {int? serialNumber}) {
    final resources = json['resources'] is Map ? Map<String, dynamic>.from(json['resources']) : <String, dynamic>{};
    return CounsellingRow(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      name: json['name']?.toString().trim() ?? '',
      state: json['state']?.toString().trim() ?? '',
      stateType: json['state_type']?.toString().trim() ?? '',
      counsellingType: json['counselling_type']?.toString().trim() ?? '',
      officialWebsiteUrl: resources['official_website']?.toString().trim(),
      registrationUrl: resources['registration']?.toString().trim(),
      prospectsUrl: resources['prospects']?.toString().trim(),
      round: json['round']?.toString().trim(),
      startDate: json['start_date']?.toString().trim(),
      endDate: json['end_date']?.toString().trim(),
      sNo: serialNumber,
    );
  }
}

class CounsellingController extends GetxController {
  final RxString selectedCounsellingType = 'Select Counselling Type'.obs;
  final RxString selectedCounsellingTypeId = ''.obs;
  final RxString selectedStateType = 'Select State Type'.obs;
  final RxString selectedStateTypeId = ''.obs;
  final RxString selectedState = 'All State'.obs;
  final RxString selectedStateId = ''.obs;
  final RxString searchQuery = ''.obs;

  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  final RxList<FilterItem> counsellingTypeFilters = <FilterItem>[].obs;
  final RxList<FilterItem> stateTypeFilters = <FilterItem>[].obs;
  
  List<String> get states => ['All State', ...stateFilters.map((e) => e.name)];
  List<String> get counsellingTypes => counsellingTypeFilters.isEmpty
      ? ['Select Counselling Type', 'State', 'MCC']
      : ['Select Counselling Type', ...counsellingTypeFilters.map((e) => e.name)];
  List<String> get stateTypes => stateTypeFilters.isEmpty
      ? ['Select State Type', 'All India', 'Closed State', 'Northeast Closed State', 'Open State']
      : ['Select State Type', ...stateTypeFilters.map((e) => e.name)];

  late List<CounsellingRow> _allRows;
  final RxList<CounsellingRow> filteredRows = <CounsellingRow>[].obs;
  final RxBool filtersLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _allRows = [];
    loadFilters();
    loadCounsellingData();
  }

  Future<void> loadFilters() async {
    filtersLoading.value = true;
    final statesFuture = FiltersApi.getStates(showLoader: false);
    final counsellingFuture = FiltersApi.getCounsellingTypes(showLoader: false);
    final (success, stateList, _) = await statesFuture;
    final (ctOk, counsellingList, _) = await counsellingFuture;
    filtersLoading.value = false;
    if (success && stateList.isNotEmpty) {
      stateFilters.assignAll(stateList);
    }
    if (ctOk && counsellingList.isNotEmpty) {
      counsellingTypeFilters.assignAll(counsellingList);
      if (selectedCounsellingTypeId.value.isEmpty) {
        selectedCounsellingType.value = counsellingList.first.name;
        selectedCounsellingTypeId.value = counsellingList.first.id;
      }
    }
    // State types will be loaded from API response
  }

  Future<void> loadCounsellingData() async {
    final stateId = selectedStateId.value.isNotEmpty 
        ? selectedStateId.value 
        : (stateFilters.isNotEmpty ? stateFilters.first.id : '0');
    final counsellingTypeId = selectedCounsellingTypeId.value.isNotEmpty
        ? selectedCounsellingTypeId.value
        : (counsellingTypeFilters.isNotEmpty ? counsellingTypeFilters.first.id : '1');
    final (success, data, errorMessage) = await CounsellingApi.getCounselling(
      stateId: stateId,
      counsellingTypeId: counsellingTypeId,
      showLoader: false,
    );
    if (!success || data == null) {
      _allRows = _buildSampleRows();
      _applyFilters();
      return;
    }
    
    // Parse filters from response
    _parseFiltersFromResponse(data);
    
    // Parse counselling list
    final rawList = data['counselling'];
    final rows = <CounsellingRow>[];
    if (rawList is List) {
      int sNo = 0;
      for (final e in rawList) {
        if (e is Map) {
          sNo++;
          try {
            rows.add(CounsellingRow.fromJson(Map<String, dynamic>.from(e), serialNumber: sNo));
          } catch (ex) {
            // Skip invalid entries
            continue;
          }
        }
      }
    }
    
    // Parse pagination info (stored for future use if needed)
    // final pagination = data['pagination'];
    
    _allRows = rows.isEmpty ? _buildSampleRows() : rows;
    _applyFilters();
  }
  
  void _parseFiltersFromResponse(Map<String, dynamic> data) {
    final filters = data['filters'];
    if (filters is! Map) return;
    final map = Map<String, dynamic>.from(filters);
    
    // Parse counselling types
    final counsellingList = map['counselling_types'];
    if (counsellingList is List) {
      final list = <FilterItem>[];
      for (final e in counsellingList) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          final id = (m['id']?.toString() ?? '').trim();
          final name = (m['name']?.toString() ?? '').trim();
          if (name.isNotEmpty) list.add(FilterItem(id: id, name: name));
        }
      }
      if (list.isNotEmpty) {
        counsellingTypeFilters.assignAll(list);
        if (selectedCounsellingTypeId.value.isEmpty && list.isNotEmpty) {
          selectedCounsellingType.value = list.first.name;
          selectedCounsellingTypeId.value = list.first.id;
        }
      }
    }
    
    // Parse state types
    final stateTypeList = map['state_types'];
    if (stateTypeList is List) {
      final list = <FilterItem>[];
      for (final e in stateTypeList) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          final id = (m['id']?.toString() ?? '').trim();
          final name = (m['name']?.toString() ?? '').trim();
          if (name.isNotEmpty) list.add(FilterItem(id: id, name: name));
        }
      }
      if (list.isNotEmpty) {
        stateTypeFilters.assignAll(list);
      }
    }
  }

  @override
  Future<void> refresh() async {
    await loadFilters();
    await loadCounsellingData();
  }

  List<CounsellingRow> _buildSampleRows() {
    return [
      CounsellingRow(
        id: 1,
        name: 'Admission Committee for Professional Medical Educational Courses (ACPMEC)',
        state: 'Gujarat',
        stateType: 'Closed State',
        counsellingType: 'State',
        officialWebsiteUrl: 'https://medadmgujarat.org/',
        registrationUrl: 'https://docs.google.com/forms/d/e/1FAIpQLScyvhOx8RI5jePjaP3ub9ZJHb3vWHoCYa4Jx3LlU2ShFj7fjQ/viewform',
        prospectsUrl: 'https://drive.google.com/file/d/1GUfqUqOV5rByoldY-TAwir1tnerAPO_f/view',
        sNo: 1,
      ),
    ];
  }

  void setCounsellingType(String v) {
    selectedCounsellingType.value = v;
    if (v == 'Select Counselling Type') {
      selectedCounsellingTypeId.value = '';
    } else {
      final match = counsellingTypeFilters.where((e) => e.name == v).toList();
      selectedCounsellingTypeId.value = match.isEmpty ? '' : match.first.id;
    }
    loadCounsellingData();
  }
  
  void setStateType(String v) {
    selectedStateType.value = v;
    if (v == 'Select State Type') {
      selectedStateTypeId.value = '';
    } else {
      final match = stateTypeFilters.where((e) => e.name == v).toList();
      selectedStateTypeId.value = match.isEmpty ? '' : match.first.id;
    }
    _applyFilters(); // Apply filter locally since state type is in the data
  }
  
  void setState(String v) {
    selectedState.value = v;
    if (v == 'All State') {
      selectedStateId.value = '';
    } else {
      final match = stateFilters.where((e) => e.name == v).toList();
      selectedStateId.value = match.isEmpty ? '' : match.first.id;
    }
    loadCounsellingData();
  }
  
  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  void _applyFilters() {
    var filtered = _allRows;
    
    // Apply state type filter
    if (selectedStateTypeId.value.isNotEmpty) {
      filtered = filtered.where((r) => r.stateType.toLowerCase() == selectedStateType.value.toLowerCase()).toList();
    }
    
    // Apply search query
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isNotEmpty) {
      filtered = filtered.where(
        (r) =>
            r.name.toLowerCase().contains(q) ||
            r.state.toLowerCase().contains(q) ||
            r.stateType.toLowerCase().contains(q) ||
            r.counsellingType.toLowerCase().contains(q),
      ).toList();
    }
    
    filteredRows.assignAll(filtered);
  }
}
