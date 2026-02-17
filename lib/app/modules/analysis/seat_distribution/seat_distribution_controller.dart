import 'dart:async';

import 'package:get/get.dart';

import '../../../../api_services/filters_api.dart';
import '../../../../api_services/seat_distribution_api.dart';
import '../../../core/snackbar/app_snackbar.dart';

class SeatDistributionRow {
  SeatDistributionRow({
    required this.sNo,
    required this.seatTypeName,
    required this.totalSeats,
    required this.totalCategories,
    required this.totalColleges,
    required this.year,
  });

  final int sNo;
  final String seatTypeName;
  final int totalSeats;
  final int totalCategories;
  final int totalColleges;
  final String year;

  factory SeatDistributionRow.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    return SeatDistributionRow(
      sNo: toInt(json['s_no']),
      seatTypeName: json['seat_type_name']?.toString() ?? '',
      totalSeats: toInt(json['total_seats']),
      totalCategories: toInt(json['total_categories']),
      totalColleges: toInt(json['total_colleges']),
      year: json['year']?.toString() ?? '',
    );
  }
}

class SeatDistributionController extends GetxController {
  final RxBool showResults = false.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxString year = ''.obs;
  final RxList<SeatDistributionRow> tableRows = <SeatDistributionRow>[].obs;

  /// State filter: GET /seat-distribution params state_id_counselling, state_id, year, course_id (optional).
  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  final RxString selectedStateId = ''.obs;
  final RxString selectedStateName = 'All States'.obs;
  final RxString selectedCourseId = ''.obs;
  final RxString selectedCourseName = 'Select Course'.obs;
  final RxString selectedYear = '2025'.obs;
  static const List<String> yearOptions = ['2025', '2024', '2023', '2022', '2021'];

  /// Course options for seat distribution filter. id -> display name. Empty id = "Select Course".
  static const List<Map<String, String>> courseOptions = [
    {'id': '', 'name': 'Select Course'},
    {'id': '1', 'name': 'MBBS'},
    {'id': '2', 'name': 'BDS'},
    {'id': '3', 'name': 'BAMS'},
    {'id': '4', 'name': 'BHMS'},
    {'id': '5', 'name': 'BUMS'},
    {'id': '6', 'name': 'B.Sc. Nursing'},
    {'id': '7', 'name': 'BPT'},
    {'id': '8', 'name': 'BVSC'},
  ];

  @override
  void onInit() {
    super.onInit();
    _loadStateFilters();
  }

  Future<void> _loadStateFilters() async {
    final (success, list, _) = await FiltersApi.getStates(showLoader: false);
    if (success && list.isNotEmpty) stateFilters.assignAll(list);
  }

  void setStateFilter(FilterItem? item) {
    if (item == null) {
      selectedStateId.value = '';
      selectedStateName.value = 'All States';
    } else {
      selectedStateId.value = item.id;
      selectedStateName.value = item.name;
    }
  }

  void setCourseFilter(String id, String name) {
    selectedCourseId.value = id;
    selectedCourseName.value = name;
  }

  void setYear(String value) => selectedYear.value = value;

  @override
  Future<void> refresh() async {
    if (!showResults.value) return;
    await loadSeatDistribution(showLoader: false);
  }

  void submit() {
    unawaited(loadSeatDistribution(showLoader: true));
  }

  Future<void> loadSeatDistribution({required bool showLoader}) async {
    error.value = '';
    isLoading.value = true;
    final stateId = selectedStateId.value.isNotEmpty ? selectedStateId.value : '0';
    final extraQuery = <String, dynamic>{
      'state_id_counselling': stateId,
      'state_id': stateId,
      'year': selectedYear.value,
    };
    final (success, data, errorMessage) = await SeatDistributionApi.getSeatDistribution(
      showLoader: showLoader,
      extraQuery: extraQuery,
    );
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load seat distribution';
      AppSnackbar.error('Seat distribution', error.value);
      tableRows.clear();
      showResults.value = false;
      return;
    }

    year.value = data['year']?.toString() ?? '';
    final rawTable = data['table_data'];
    final rows = <SeatDistributionRow>[];
    if (rawTable is List) {
      for (final e in rawTable) {
        if (e is Map) {
          rows.add(SeatDistributionRow.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    tableRows.assignAll(rows);
    showResults.value = true;
  }
}
