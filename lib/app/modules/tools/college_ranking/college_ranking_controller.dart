import 'package:get/get.dart';

import '../../../../api_services/filters_api.dart';

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
}

class CollegeRankingController extends GetxController {
  final RxString selectedState = 'Uttar Pradesh'.obs;
  final RxString selectedInstituteType = 'Select Institute Type'.obs;
  final RxString selectedCourse = 'Select Course'.obs;
  final RxString searchQuery = ''.obs;

  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  List<String> get states => stateFilters.isEmpty
      ? ['Select State', 'Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka']
      : ['Select State', ...stateFilters.map((e) => e.name)];

  static const List<String> instituteTypes = ['Select Institute Type', 'Government', 'Private', 'Deemed'];
  static const List<String> courses = ['Select Course', 'MBBS', 'BDS', 'MD/MS', 'BAMS', 'BHMS'];

  late final List<CollegeRankingRow> _allRows;
  final RxList<CollegeRankingRow> filteredRows = <CollegeRankingRow>[].obs;

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

  List<CollegeRankingRow> _buildSampleRows() {
    return [
      CollegeRankingRow(
        sNo: 1,
        instituteAndType: 'SCHOOL OF MEDICAL SCIENCES (SHARDA UNIVERSITY) G.NOIDA (Private)',
        state: 'Uttar Pradesh',
        degreesOffered: 'MBBS, MD/MS',
        yearOfEstablishment: '2009',
        totalSeats: '250',
        ncRanking: '2',
      ),
      CollegeRankingRow(
        sNo: 2,
        instituteAndType: 'SRI RAM MURTI SMARAK INSTITUTE OF MEDICAL SCIENCES, BAREILLY (Private)',
        state: 'Uttar Pradesh',
        degreesOffered: 'MBBS',
        yearOfEstablishment: '2012',
        totalSeats: '150',
        ncRanking: '5',
      ),
      CollegeRankingRow(
        sNo: 3,
        instituteAndType: 'MUZAFFARNAGAR MEDICAL COLLEGE, MUZAFFARNAGAR (Private)',
        state: 'Uttar Pradesh',
        degreesOffered: 'MBBS',
        yearOfEstablishment: '2014',
        totalSeats: '200',
        ncRanking: '8',
      ),
      CollegeRankingRow(
        sNo: 4,
        instituteAndType: 'EXAMPLE GOVERNMENT MEDICAL COLLEGE (Government)',
        state: 'Uttar Pradesh',
        degreesOffered: 'MBBS, MD/MS',
        yearOfEstablishment: '1985',
        totalSeats: '250',
        ncRanking: '1',
      ),
      CollegeRankingRow(
        sNo: 5,
        instituteAndType: 'DEEMED UNIVERSITY MEDICAL COLLEGE (Deemed)',
        state: 'Uttar Pradesh',
        degreesOffered: 'MBBS, MD/MS, BDS',
        yearOfEstablishment: '2005',
        totalSeats: '100',
        ncRanking: '3',
      ),
    ];
  }

  void setState(String v) => selectedState.value = v;
  void setInstituteType(String v) => selectedInstituteType.value = v;
  void setCourse(String v) => selectedCourse.value = v;
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
