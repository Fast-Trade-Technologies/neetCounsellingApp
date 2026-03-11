import 'dart:async';

import 'package:flutter/material.dart';
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

  factory SeatDistributionRow.fromJson(Map<String, dynamic> json, {int index = 0}) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    return SeatDistributionRow(
      sNo: toInt(json['s_no'] ?? json['sNo'] ?? (index + 1)),
      seatTypeName: json['seat_type_name']?.toString().trim() ?? '',
      totalSeats: toInt(json['total_seats']),
      totalCategories: toInt(json['total_categories']),
      totalColleges: toInt(json['total_colleges']),
      year: json['year']?.toString() ?? '',
    );
  }
}

/// One node in tree_data: name, value, optional children.
class SeatTreeNode {
  SeatTreeNode({
    required this.name,
    required this.value,
    this.children = const [],
  });

  final String name;
  final int value;
  final List<SeatTreeChild> children;

  static SeatTreeNode? fromJson(dynamic json) {
    if (json is! Map) return null;
    final map = Map<String, dynamic>.from(json);
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    final childrenRaw = map['children'];
    final childList = <SeatTreeChild>[];
    if (childrenRaw is List) {
      for (final c in childrenRaw) {
        if (c is Map) {
          final cm = Map<String, dynamic>.from(c);
          childList.add(SeatTreeChild(
            name: (cm['name']?.toString() ?? '').trim(),
            value: toInt(cm['value']),
          ));
        }
      }
    }
    return SeatTreeNode(
      name: (map['name']?.toString() ?? '').trim(),
      value: toInt(map['value']),
      children: childList,
    );
  }
}

class SeatTreeChild {
  SeatTreeChild({required this.name, required this.value});
  final String name;
  final int value;
}

class SeatDistributionController extends GetxController {
  final RxBool showResults = false.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxString year = ''.obs;
  final RxList<SeatDistributionRow> tableRows = <SeatDistributionRow>[].obs;
  /// From API tree_data: hierarchical breakdown (e.g. Government State Quota → EWS, ST, SC...).
  final RxList<SeatTreeNode> treeData = <SeatTreeNode>[].obs;
  /// From API seat_labels / seat_series for chart (fallback if table_data empty).
  final RxList<String> seatLabels = <String>[].obs;
  final RxList<int> seatSeries = <int>[].obs;

  /// State filter: GET /seat-distribution params state_id, year, course_id (optional).
  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  final RxString selectedStateId = '26'.obs;
  final RxString selectedStateName = 'uttar pradesh'.obs;
  /// Counselling type filter: from API data.filters.counselling_types.
  final RxList<FilterItem> counsellingTypeFilters = <FilterItem>[].obs;
  final RxString selectedCounsellingTypeId = ''.obs;
  final RxString selectedCounsellingTypeName = 'Select Counselling Type'.obs;
  final RxString selectedCourseId = ''.obs;
  final RxString selectedCourseName = 'Select Course'.obs;
  final RxString selectedYear = '2025'.obs;
  final RxList<String> yearOptions = <String>['2025', '2024'].obs;

  /// Course options for seat distribution filter. id -> display name. Empty id = "Select Course".
  static const List<Map<String, String>> courseOptions = [
    {'id': '', 'name': 'Select Course'},
    {'id': '1', 'name': 'MBBS'},
    {'id': '2', 'name': 'BDS'},
  ];

  @override
  void onInit() {
    super.onInit();
    unawaited(loadSeatDistribution(showLoader: false));
  }

  void setStateFilter(FilterItem? item) {
    if (item == null) {
      selectedStateId.value = '';
      selectedStateName.value = 'uttar pradesh';
    } else {
      selectedStateId.value = item.id;
      selectedStateName.value = item.name;
    }
  }

  void setCourseFilter(String id, String name) {
    selectedCourseId.value = id;
    selectedCourseName.value = name;
  }

  void setCounsellingType(FilterItem? item) {
    if (item == null) {
      selectedCounsellingTypeId.value = '';
      selectedCounsellingTypeName.value = 'Select Counselling Type';
    } else {
      selectedCounsellingTypeId.value = item.id;
      selectedCounsellingTypeName.value = item.name;
    }
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
      'state_id': stateId,
      'year': selectedYear.value,
    };
    if (selectedCourseId.value.isNotEmpty) {
      extraQuery['course_id'] = selectedCourseId.value;
    }
    if (selectedCounsellingTypeId.value.isNotEmpty) {
      extraQuery['state_id_counselling'] = selectedCounsellingTypeId.value;
    }
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

    // Parse filters for states, counselling types, and years from API response.
    final filters = data['filters'];
    if (filters is Map) {
      // States
      final states = filters['states'];
      if (states is List) {
        final list = <FilterItem>[];
        for (final s in states) {
          if (s is Map) {
            final m = Map<String, dynamic>.from(s);
            final id = m['id']?.toString() ?? '';
            final name = m['name']?.toString() ?? '';
            if (id.isNotEmpty && name.isNotEmpty) {
              list.add(FilterItem(id: id, name: name));
            }
          }
        }
        if (list.isNotEmpty) {
          stateFilters.assignAll(list);

          // Only auto-select default when there is no valid user selection yet.
          final hasExisting =
              selectedStateId.value.isNotEmpty && list.any((s) => s.id == selectedStateId.value);
          if (!hasExisting) {
            final apiSelectedStateName = data['selected_state_name']?.toString();
            FilterItem? chosen;
            if (apiSelectedStateName != null && apiSelectedStateName.trim().isNotEmpty) {
              final target = apiSelectedStateName.trim().toLowerCase();
              for (final s in list) {
                if (s.name.trim().toLowerCase() == target) {
                  chosen = s;
                  break;
                }
              }
            }
            if (chosen == null) {
              for (final s in list) {
                if (s.name.trim().toLowerCase() == 'uttar pradesh') {
                  chosen = s;
                  break;
                }
              }
            }
            chosen ??= list.first;
            selectedStateId.value = chosen.id;
            selectedStateName.value = chosen.name;
          }
        }
      }

      // Counselling types
      final counsellingTypes = filters['counselling_types'];
      if (counsellingTypes is List) {
        final list = <FilterItem>[];
        for (final c in counsellingTypes) {
          if (c is Map) {
            final m = Map<String, dynamic>.from(c);
            final id = m['id']?.toString() ?? '';
            final name = m['name']?.toString() ?? '';
            if (id.isNotEmpty && name.isNotEmpty) {
              list.add(FilterItem(id: id, name: name));
            }
          }
        }
        if (list.isNotEmpty) {
          counsellingTypeFilters.assignAll(list);

          final hasExisting = selectedCounsellingTypeId.value.isNotEmpty &&
              list.any((c) => c.id == selectedCounsellingTypeId.value);
          if (!hasExisting) {
            FilterItem chosen = list.first;
            for (final c in list) {
              if (c.name.trim().toLowerCase() == 'state') {
                chosen = c;
                break;
              }
            }
            selectedCounsellingTypeId.value = chosen.id;
            selectedCounsellingTypeName.value = chosen.name;
          }
        }
      }

      // Years
      final years = filters['years'];
      if (years is List) {
        final parsedYears = <String>[];
        for (final y in years) {
          final ys = y?.toString();
          if (ys != null && ys.isNotEmpty) {
            parsedYears.add(ys);
          }
        }
        if (parsedYears.isNotEmpty) {
          yearOptions.assignAll(parsedYears);
          final hasExisting =
              selectedYear.value.isNotEmpty && parsedYears.contains(selectedYear.value);
          if (!hasExisting) {
            final apiYear = data['year']?.toString();
            if (apiYear != null && apiYear.isNotEmpty && parsedYears.contains(apiYear)) {
              selectedYear.value = apiYear;
            } else {
              selectedYear.value = parsedYears.first;
            }
          }
        }
      }
    }
    final rawTable = data['table_data'];
    final rows = <SeatDistributionRow>[];
    if (rawTable is List) {
      for (int i = 0; i < rawTable.length; i++) {
        final e = rawTable[i];
        if (e is Map) {
          rows.add(SeatDistributionRow.fromJson(Map<String, dynamic>.from(e), index: i));
        }
      }
    }
    tableRows.assignAll(rows);

    final rawTree = data['tree_data'];

    final treeList = <SeatTreeNode>[];
    final labels = <String>[];
    final series = <int>[];

    if (rawTree is List) {
      for (final e in rawTree) {
        final node = SeatTreeNode.fromJson(e);

        if (node != null) {
          treeList.add(node);

          /// add all children for graph
          for (final child in node.children) {
            labels.add(child.name.trim());
            series.add(child.value);
          }
        }
      }
    }

    treeData.assignAll(treeList);
    seatLabels.assignAll(labels);
    seatSeries.assignAll(series);

    debugPrint("tree --- $treeList");
    debugPrint("labels --- $labels");
    debugPrint("series --- $series");

    showResults.value = true;

    debugPrint("tree --- $treeList");
    debugPrint("labels --- $labels");
    debugPrint("series --- $series");

    // for (final node in treeList) {
    //   for (final child in node.children) {
    //     labels.add(child.name.trim());
    //     series.add(child.value);
    //   }
    // }
    //
    // seatLabels.assignAll(labels);
    // seatSeries.assignAll(series);

    showResults.value = true;
  }
}
