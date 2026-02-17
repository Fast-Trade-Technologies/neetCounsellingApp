import 'package:get/get.dart';

import '../../../../api_services/courses_api.dart';
import '../../../core/snackbar/app_snackbar.dart';

/// Single filter option from /courses API response (data.filters).
class CourseFilterItem {
  CourseFilterItem({required this.id, required this.name});
  final String id;
  final String name;
}

/// Item for graph from data.tree_data.
class TreeDataItem {
  TreeDataItem({this.label, this.value, this.name});
  final String? label;
  final String? name;
  final num? value;
  String get displayName => label ?? name ?? '';
}

class CourseItem {
  CourseItem({
    required this.sNo,
    required this.degreeType,
    required this.degreeTerms,
    required this.year,
    required this.durationShort,
  });

  final int sNo;
  final String degreeType;
  final String degreeTerms;
  final String year;
  final String durationShort;

  factory CourseItem.fromJson(Map<String, dynamic> json) {
    final year = json['year']?.toString() ?? '';
    return CourseItem(
      sNo: json['s_no'] is int
          ? json['s_no'] as int
          : int.tryParse(json['s_no']?.toString() ?? '') ?? 0,
      degreeType: json['degree_type']?.toString() ?? '',
      degreeTerms: json['degree_terms']?.toString() ?? json['name']?.toString() ?? '',
      year: year,
      durationShort: _shortenYear(year),
    );
  }

  static String _shortenYear(String year) {
    final y = year.trim();
    if (y.isEmpty) return '';
    final lower = y.toLowerCase();
    if (lower.contains('internship')) {
      final parts = y.split('(');
      final first = parts.first.trim();
      final intern = parts.length > 1 ? parts[1].replaceAll(')', '').trim() : '';
      final f = first.replaceAll('Years', 'Y').replaceAll('Year', 'Y').replaceAll(' ', '');
      final i = intern
          .replaceAll('Years', 'Y')
          .replaceAll('Year', 'Y')
          .replaceAll('Internship', 'Int.')
          .replaceAll(' ', '');
      return i.isEmpty ? f : '$f + $i';
    }
    return y;
  }
}

class CoursesController extends GetxController {
  final RxString selectedDegreeTypeName = 'Select'.obs;
  final RxString selectedDegreeTypeId = ''.obs;
  final RxString selectedCourseName = 'All'.obs;
  final RxString selectedCourseId = ''.obs;
  final RxInt entriesPerPage = 10.obs;
  final RxString searchQuery = ''.obs;

  final RxBool filtersLoading = true.obs;
  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxList<CourseFilterItem> degreeTypesFromApi = <CourseFilterItem>[].obs;
  final RxList<CourseFilterItem> seatMatrixCoursesFromApi = <CourseFilterItem>[].obs;
  final RxList<TreeDataItem> treeDataForChart = <TreeDataItem>[].obs;

  List<String> get degreeTypeNames =>
      degreeTypesFromApi.isEmpty ? ['Select'] : degreeTypesFromApi.map((e) => e.name).toList();
  List<String> get courseNames =>
      seatMatrixCoursesFromApi.isEmpty
          ? ['All']
          : ['All', ...seatMatrixCoursesFromApi.map((e) => e.name.trim())];

  static const List<int> entriesOptions = [10, 25, 50];

  final List<CourseItem> _allCourses = <CourseItem>[];
  final RxList<CourseItem> filteredCourses = <CourseItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadFiltersFirst();
  }

  @override
  Future<void> refresh() async {
    await loadCoursesWithFilters(showLoader: false);
  }

  /// First time: GET /courses with only nLoginUserIdNo to get filters.
  Future<void> loadFiltersFirst() async {
    filtersLoading.value = true;
    error.value = '';
    final (success, data, errorMessage) = await CoursesApi.getCourses(
      queryParameters: null,
      showLoader: false,
    );
    filtersLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load filters';
      degreeTypesFromApi.clear();
      seatMatrixCoursesFromApi.clear();
      return;
    }

    final filters = data['filters'];
    if (filters is Map) {
      final map = Map<String, dynamic>.from(filters);
      degreeTypesFromApi.assignAll(_parseFilterList(map['degree_types']));
      seatMatrixCoursesFromApi.assignAll(_parseFilterList(map['seat_matrix_courses']));
    }

    if (degreeTypesFromApi.isNotEmpty && selectedDegreeTypeId.value.isEmpty) {
      selectedDegreeTypeName.value = degreeTypesFromApi.first.name;
      selectedDegreeTypeId.value = degreeTypesFromApi.first.id;
    }
    selectedCourseName.value = 'All';
    selectedCourseId.value = '';

    await loadCoursesWithFilters(showLoader: true);
  }

  static List<CourseFilterItem> _parseFilterList(dynamic raw) {
    if (raw is! List) return [];
    final list = <CourseFilterItem>[];
    for (final e in raw) {
      if (e is Map) {
        final id = e['id']?.toString() ?? '';
        final name = e['name']?.toString() ?? '';
        if (name.isNotEmpty) list.add(CourseFilterItem(id: id, name: name));
      }
    }
    return list;
  }

  /// GET /courses with selected filter params; update list and graph from data.courses and data.tree_data.
  Future<void> loadCoursesWithFilters({bool showLoader = true}) async {
    error.value = '';
    isLoading.value = true;
    final query = <String, dynamic>{};
    if (selectedDegreeTypeId.value.isNotEmpty) query['degree_type_id'] = selectedDegreeTypeId.value;
    if (selectedCourseId.value.isNotEmpty) query['course_id'] = selectedCourseId.value;

    final (success, data, errorMessage) = await CoursesApi.getCourses(
      queryParameters: query.isEmpty ? null : query,
      showLoader: showLoader,
    );
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load courses';
      AppSnackbar.error('Courses', error.value);
      _allCourses.clear();
      filteredCourses.clear();
      treeDataForChart.clear();
      return;
    }

    final rawList = data['courses'];
    final list = <CourseItem>[];
    if (rawList is List) {
      for (final e in rawList) {
        if (e is Map) {
          list.add(CourseItem.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }
    _allCourses
      ..clear()
      ..addAll(list);

    final rawTree = data['tree_data'];
    final treeList = <TreeDataItem>[];
    if (rawTree is List) {
      for (final e in rawTree) {
        if (e is Map) {
          final m = Map<String, dynamic>.from(e);
          final label = m['label']?.toString();
          final name = m['name']?.toString();
          final value = m['value'] is num ? m['value'] as num : num.tryParse(m['value']?.toString() ?? '');
          treeList.add(TreeDataItem(label: label, name: name, value: value));
        }
      }
    }
    treeDataForChart.assignAll(treeList);

    _applyFilters();
  }

  void setDegreeType(String name) {
    selectedDegreeTypeName.value = name;
    final match = degreeTypesFromApi.where((e) => e.name == name).toList();
    selectedDegreeTypeId.value = match.isEmpty ? '' : match.first.id;
    loadCoursesWithFilters(showLoader: false);
  }

  void setCourse(String name) {
    selectedCourseName.value = name;
    if (name == 'All') {
      selectedCourseId.value = '';
    } else {
      final match = seatMatrixCoursesFromApi.where((e) => e.name.trim() == name).toList();
      selectedCourseId.value = match.isEmpty ? '' : match.first.id;
    }
    loadCoursesWithFilters(showLoader: false);
  }

  void setEntriesPerPage(int v) => entriesPerPage.value = v;

  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  void _applyFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    var list = _allCourses.where((c) {
      if (q.isEmpty) return true;
      return c.degreeType.toLowerCase().contains(q) ||
          c.degreeTerms.toLowerCase().contains(q) ||
          c.year.toLowerCase().contains(q);
    }).toList();
    filteredCourses.assignAll(list);
  }

  List<CourseItem> get paginatedCourses {
    final list = filteredCourses;
    final perPage = entriesPerPage.value;
    final end = list.length < perPage ? list.length : perPage;
    return list.take(end).toList();
  }

  int get totalEntries => filteredCourses.length;
}
