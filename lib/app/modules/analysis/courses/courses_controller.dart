import 'package:get/get.dart';

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
}

class CoursesController extends GetxController {
  final RxString selectedDegreeType = 'Degree'.obs;
  final RxString selectedDegreeTerms = 'All'.obs;
  final RxInt entriesPerPage = 10.obs;
  final RxString searchQuery = ''.obs;

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

  late final List<CourseItem> _allCourses;
  final RxList<CourseItem> filteredCourses = <CourseItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _allCourses = _buildCourses();
    _applyFilters();
  }

  List<CourseItem> _buildCourses() {
    return [
      CourseItem(sNo: 1, degreeType: 'Degree', degreeTerms: 'MBBS', year: '5.5 Years (1 Year Internship)', durationShort: '5.5Y + 1Y Int.'),
      CourseItem(sNo: 2, degreeType: 'Degree', degreeTerms: 'BDS', year: '4 Years (1 Year Internship)', durationShort: '4Y + 1Y Int.'),
      CourseItem(sNo: 3, degreeType: 'Degree', degreeTerms: 'BAMS', year: '5.5 Years (1 Year Internship)', durationShort: '5.5Y + 1Y Int.'),
      CourseItem(sNo: 4, degreeType: 'Degree', degreeTerms: 'BHMS', year: '5.5 Years (1 Year Internship)', durationShort: '5.5Y + 1Y Int.'),
      CourseItem(sNo: 5, degreeType: 'Degree', degreeTerms: 'BUMS', year: '5.5 Years (1 Year Internship)', durationShort: '5.5Y + 1Y Int.'),
      CourseItem(sNo: 6, degreeType: 'Degree', degreeTerms: 'B.Sc. Nursing', year: '4-year', durationShort: '4-Y'),
      CourseItem(sNo: 7, degreeType: 'Degree', degreeTerms: 'BPT', year: '4.5 Years (6 months Internship)', durationShort: '4.5Y (6 months Int.)'),
      CourseItem(sNo: 8, degreeType: 'Degree', degreeTerms: 'BVSC', year: '5.5 Years (1 Year Internship)', durationShort: '5.5Y + 1Y Int.'),
      CourseItem(sNo: 9, degreeType: 'Degree', degreeTerms: 'BNYS', year: '5.5 Years (1 Year Internship)', durationShort: '5.5Y + 1Y Int.'),
      CourseItem(sNo: 10, degreeType: 'Degree', degreeTerms: 'Pharm.D.', year: '6 Years (1 Year Internship)', durationShort: '6Y + 1Y Int.'),
    ];
  }

  void setDegreeType(String v) => selectedDegreeType.value = v;
  void setDegreeTerms(String v) => selectedDegreeTerms.value = v;
  void setEntriesPerPage(int v) => entriesPerPage.value = v;
  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  void _applyFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    var list = _allCourses.where((c) {
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
