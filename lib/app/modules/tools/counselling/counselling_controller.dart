import 'package:get/get.dart';

import '../../../../api_services/counselling_api.dart';
import '../../../../api_services/filters_api.dart';

class CounsellingRow {
  CounsellingRow({
    required this.sNo,
    required this.counselling,
    required this.state,
    required this.typeOfState,
    required this.counsellingType,
    this.officialWebsiteUrl,
    this.registrationUrl,
    this.prospectsUrl,
  });

  final int sNo;
  final String counselling;
  final String state;
  final String typeOfState;
  final String counsellingType;
  final String? officialWebsiteUrl;
  final String? registrationUrl;
  final String? prospectsUrl;
}

class CounsellingController extends GetxController {
  final RxString selectedCounsellingType = 'Select Counselling Type'.obs;
  final RxString selectedCounsellingTypeId = ''.obs;
  final RxString selectedStateType = 'Select State Type'.obs;
  final RxString selectedState = 'All State'.obs;
  final RxString selectedStateId = ''.obs;
  final RxString searchQuery = ''.obs;

  static const List<String> stateTypes = [
    'Select State Type',
    'Open State',
    'Closed State',
  ];

  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  final RxList<FilterItem> counsellingTypeFilters = <FilterItem>[].obs;
  List<String> get states => ['All State', ...stateFilters.map((e) => e.name)];
  List<String> get counsellingTypes => counsellingTypeFilters.isEmpty
      ? ['Select Counselling Type', 'State', 'MCC']
      : ['Select Counselling Type', ...counsellingTypeFilters.map((e) => e.name)];

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
    final rawList = data['counselling'];
    final rows = <CounsellingRow>[];
    if (rawList is List) {
      int sNo = 0;
      for (final e in rawList) {
        if (e is Map) {
          sNo++;
          rows.add(CounsellingRow(
            sNo: sNo,
            counselling: e['state']?.toString() ?? '',
            state: e['state']?.toString() ?? '',
            typeOfState: '',
            counsellingType: e['counselling_type']?.toString() ?? 'State',
            officialWebsiteUrl: null,
            registrationUrl: null,
            prospectsUrl: null,
          ));
        }
      }
    }
    _allRows = rows.isEmpty ? _buildSampleRows() : rows;
    _applyFilters();
  }

  @override
  Future<void> refresh() async {
    await loadFilters();
    await loadCounsellingData();
  }

  List<CounsellingRow> _buildSampleRows() {
    return [
      CounsellingRow(
        sNo: 1,
        counselling: 'Admission Committee for Professional Medical Educational Courses (ACPMEC)',
        state: 'Gujarat',
        typeOfState: 'Closed State',
        counsellingType: 'State',
        officialWebsiteUrl: 'https://example.com',
        registrationUrl: 'https://example.com/reg',
        prospectsUrl: 'https://example.com/prospects',
      ),
      CounsellingRow(
        sNo: 2,
        counselling: 'Andaman & Nicobar Islands Institute of Medical Sciences (ANIIMS)',
        state: 'Andaman and Nicobar Islands',
        typeOfState: 'Open State',
        counsellingType: 'State',
      ),
      CounsellingRow(
        sNo: 3,
        counselling: 'Uttar Pradesh NEET UG Counselling Authority',
        state: 'Uttar Pradesh',
        typeOfState: 'Closed State',
        counsellingType: 'State',
      ),
      CounsellingRow(
        sNo: 4,
        counselling: 'Directorate of Medical Education (DME) Maharashtra',
        state: 'Maharashtra',
        typeOfState: 'Open State',
        counsellingType: 'State',
      ),
      CounsellingRow(
        sNo: 5,
        counselling: 'Rajasthan NEET UG Counselling Board',
        state: 'Rajasthan',
        typeOfState: 'Closed State',
        counsellingType: 'State',
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
  void setStateType(String v) => selectedStateType.value = v;
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
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredRows.assignAll(_allRows);
    } else {
      filteredRows.assignAll(
        _allRows.where(
          (r) =>
              r.counselling.toLowerCase().contains(q) ||
              r.state.toLowerCase().contains(q) ||
              r.typeOfState.toLowerCase().contains(q) ||
              r.counsellingType.toLowerCase().contains(q),
        ),
      );
    }
  }
}
