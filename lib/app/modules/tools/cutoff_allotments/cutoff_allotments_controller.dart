import 'package:get/get.dart';

import '../../../../api_services/filters_api.dart';

class CutoffRow {
  CutoffRow({
    required this.sNo,
    required this.instituteAndType,
    required this.course,
    required this.quota,
    required this.category,
    required this.fees,
    required this.r1,
    required this.r2,
    required this.r3,
    required this.r4,
  });

  final int sNo;
  final String instituteAndType;
  final String course;
  final String quota;
  final String category;
  final String fees;
  final String r1;
  final String r2;
  final String r3;
  final String r4;
}

class CutoffAllotmentsController extends GetxController {
  final RxString selectedState = 'Uttar Pradesh'.obs;
  final RxString selectedInstituteType = 'Select Institute Type'.obs;
  final RxString selectedQuota = 'Select Quota'.obs;
  final RxString selectedCategory = 'Select Category'.obs;
  final RxString selectedCourse = 'Select Course'.obs;
  final RxString selectedYear = '2024'.obs;
  final RxInt entriesPerPage = 10.obs;
  final RxString searchQuery = ''.obs;

  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  List<String> get states => stateFilters.isEmpty
      ? ['Select State', 'Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka']
      : ['Select State', ...stateFilters.map((e) => e.name)];

  static const List<String> instituteTypes = ['Select Institute Type', 'Government', 'Private', 'Deemed'];
  static const List<String> quotas = ['Select Quota', 'General', 'OBC', 'SC', 'ST', 'EWS'];
  static const List<String> categories = ['Select Category', 'General', 'OBC', 'SC', 'ST', 'EWS', 'N/A'];
  static const List<String> courses = ['Select Course', 'MBBS', 'BDS', 'BAMS', 'BHMS'];
  static const List<String> years = ['2024', '2023', '2022'];
  static const List<int> entriesOptions = [10, 25, 50];

  List<int> get entriesOptionsList => entriesOptions;

  late final List<CutoffRow> _allRows;
  final RxList<CutoffRow> filteredRows = <CutoffRow>[].obs;

  @override
  void onInit() {
    super.onInit();
    _allRows = _buildSampleRows();
    _applyFilters();
    _loadStateFilters();
  }

  Future<void> _loadStateFilters() async {
    final (success, stateList, _) = await FiltersApi.getStates(showLoader: false);
    if (success && stateList.isNotEmpty) stateFilters.assignAll(stateList);
  }

  @override
  Future<void> refresh() async => _applyFilters();

  List<CutoffRow> _buildSampleRows() {
    return [
      CutoffRow(
        sNo: 1,
        instituteAndType: 'SRI RAM MURTI SMARAK INSTITUTE OF MEDICAL SCIENCES, BAREILLY (Private)',
        course: 'MBBS',
        quota: 'General',
        category: 'N/A',
        fees: '1648512',
        r1: '101256',
        r2: '98822',
        r3: '68947',
        r4: '-',
      ),
      CutoffRow(
        sNo: 2,
        instituteAndType: 'SRI RAM MURTI SMARAK INSTITUTE OF MEDICAL SCIENCES, BAREILLY (Private)',
        course: 'MBBS',
        quota: 'General',
        category: 'N/A',
        fees: '1648512',
        r1: '101256',
        r2: '98822',
        r3: '68947',
        r4: '-',
      ),
      CutoffRow(
        sNo: 3,
        instituteAndType: 'EXAMPLE GOVERNMENT MEDICAL COLLEGE (Government)',
        course: 'MBBS',
        quota: 'General',
        category: 'N/A',
        fees: 'N/A',
        r1: '45210',
        r2: '44100',
        r3: '43800',
        r4: '-',
      ),
      CutoffRow(
        sNo: 4,
        instituteAndType: 'ANOTHER PRIVATE MEDICAL COLLEGE, LUCKNOW (Private)',
        course: 'MBBS',
        quota: 'General',
        category: 'N/A',
        fees: '1850000',
        r1: '112000',
        r2: '108500',
        r3: '-',
        r4: '-',
      ),
      CutoffRow(
        sNo: 5,
        instituteAndType: 'DEEMED UNIVERSITY MEDICAL COLLEGE (Deemed)',
        course: 'MBBS',
        quota: 'General',
        category: 'N/A',
        fees: '2400000',
        r1: '98500',
        r2: '96200',
        r3: '95100',
        r4: '94500',
      ),
    ];
  }

  void setState(String v) => selectedState.value = v;
  void setInstituteType(String v) => selectedInstituteType.value = v;
  void setQuota(String v) => selectedQuota.value = v;
  void setCategory(String v) => selectedCategory.value = v;
  void setCourse(String v) => selectedCourse.value = v;
  void setYear(String v) => selectedYear.value = v;
  void setEntriesPerPage(int v) => entriesPerPage.value = v;
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
              r.fees.contains(q),
        ),
      );
    }
  }

  List<CutoffRow> get paginatedRows {
    final list = filteredRows;
    final perPage = entriesPerPage.value;
    return list.take(perPage).toList();
  }

  int get totalEntries => filteredRows.length;
}
