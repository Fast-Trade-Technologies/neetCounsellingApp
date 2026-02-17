import 'package:get/get.dart';

import '../../../../api_services/courses_api.dart';
import '../../../core/snackbar/app_snackbar.dart';

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
      degreeTerms: json['degree_terms']?.toString() ?? '',
      year: year,
      durationShort: _shortenYear(year),
    );
  }

  static String _shortenYear(String year) {
    final y = year.trim();
    if (y.isEmpty) return '';
    // Common formats like: "5.5 Years (1 Year Internship)" → "5.5Y + 1Y Int."
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
  final RxString selectedDegreeType = 'Degree'.obs;
  final RxString selectedDegreeTerms = 'All'.obs;
  final RxInt entriesPerPage = 10.obs;
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  static const List<String> degreeTypes = ['Degree', 'Diploma'];
  static const List<String> degreeTermsList = [
    'All',
    'MBBS',
    'BDS',
    'BAMS',
    'BHMS',
    'BUMS',
    'B.Sc. Nursing',
    'BPT',
    'BVSC',
    'BNYS',
    'Pharm.D.',
  ];
  static const List<int> entriesOptions = [10, 25, 50];

  List<String> get degreeTypesList => degreeTypes;
  List<String> get degreeTerms => degreeTermsList;
  List<int> get entriesOptionsList => entriesOptions;

  final List<CourseItem> _allCourses = <CourseItem>[];
  final RxList<CourseItem> filteredCourses = <CourseItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadCourses();
  }

  @override
  Future<void> refresh() async => loadCourses(showLoader: false);

  /// GET /courses params: course_id, roles, degree_type_id (Postman).
  /// Maps UI: Degree=1, Diploma=2; MBBS=1, BDS=2, BAMS=3, etc.
  static const Map<String, String> _degreeTypeIds = {'Degree': '1', 'Diploma': '2'};
  static const Map<String, String> _courseIds = {
    'All': '',
    'MBBS': '1',
    'BDS': '2',
    'BAMS': '3',
    'BHMS': '4',
    'BUMS': '5',
    'B.Sc. Nursing': '6',
    'BPT': '7',
    'BVSC': '8',
    'BNYS': '9',
    'Pharm.D.': '10',
  };

  Future<void> loadCourses({bool showLoader = true}) async {
    error.value = '';
    isLoading.value = true;
    final query = <String, dynamic>{};
    final dtId = _degreeTypeIds[selectedDegreeType.value];
    if (dtId != null && dtId.isNotEmpty) query['degree_type_id'] = dtId;
    final cId = _courseIds[selectedDegreeTerms.value];
    if (cId != null && cId.isNotEmpty) query['course_id'] = cId;
    query['roles'] = '2';
    final (success, data, errorMessage) = await CoursesApi.getCourses(
      showLoader: showLoader,
      queryParameters: query.isEmpty ? null : query,
    );
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load courses';
      AppSnackbar.error('Courses', error.value);
      _allCourses.clear();
      filteredCourses.clear();
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
    _applyFilters();
  }

  void setDegreeType(String v) {
    selectedDegreeType.value = v;
    loadCourses(showLoader: false);
  }

  void setDegreeTerms(String v) {
    selectedDegreeTerms.value = v;
    loadCourses(showLoader: false);
  }
  void setEntriesPerPage(int v) => entriesPerPage.value = v;
  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  void _applyFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    var list = _allCourses.where((c) {
      if (selectedDegreeType.value.isNotEmpty && c.degreeType.isNotEmpty) {
        if (selectedDegreeType.value != 'Degree' && selectedDegreeType.value != c.degreeType) {
          return false;
        }
      }
      if (selectedDegreeTerms.value != 'All' && c.degreeTerms != selectedDegreeTerms.value) return false;
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
    final end = (list.length < perPage) ? list.length : perPage;
    return list.take(end).toList();
  }

  int get totalEntries => filteredCourses.length;
}
