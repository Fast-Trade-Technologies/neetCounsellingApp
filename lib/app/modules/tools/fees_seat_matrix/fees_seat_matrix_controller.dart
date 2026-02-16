import 'package:get/get.dart';

class FeesSeatRow {
  FeesSeatRow({
    required this.sNo,
    required this.instituteAndType,
    required this.course,
    required this.quota,
    required this.category,
    required this.fees,
    required this.seats,
  });

  final int sNo;
  final String instituteAndType;
  final String course;
  final String quota;
  final String category;
  final String fees;
  final String seats;
}

class FeesSeatMatrixController extends GetxController {
  final RxString selectedState = 'Uttar Pradesh'.obs;
  final RxString selectedInstituteType = 'Select Institute Type'.obs;
  final RxString selectedQuota = 'Select Quota'.obs;
  final RxString selectedCategory = 'Select Category'.obs;
  final RxString selectedCourse = 'Select Course'.obs;
  final RxString selectedYear = '2024'.obs;
  final RxString searchQuery = ''.obs;

  static const List<String> states = ['Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka'];
  static const List<String> instituteTypes = ['Select Institute Type', 'Government', 'Private', 'Deemed'];
  static const List<String> quotas = ['Select Quota', 'General', 'OBC', 'SC', 'ST', 'EWS'];
  static const List<String> categories = ['Select Category', 'General', 'OBC', 'SC', 'ST', 'EWS', 'N/A'];
  static const List<String> courses = ['Select Course', 'MBBS', 'BDS', 'BAMS', 'BHMS'];
  static const List<String> years = ['2024', '2023', '2022'];

  late final List<FeesSeatRow> _allRows;
  final RxList<FeesSeatRow> filteredRows = <FeesSeatRow>[].obs;

  @override
  void onInit() {
    super.onInit();
    _allRows = _buildSampleRows();
    _applyFilters();
  }

  Future<void> refresh() async => _applyFilters();

  List<FeesSeatRow> _buildSampleRows() {
    return [
      FeesSeatRow(
        sNo: 1,
        instituteAndType: 'SRI RAM MURTI SMARAK INSTITUTE OF MEDICAL SCIENCES, BAREILLY (Private)',
        course: 'MBBS',
        quota: 'General',
        category: 'N/A',
        fees: '1648512',
        seats: '150',
      ),
      FeesSeatRow(
        sNo: 2,
        instituteAndType: 'MUZAFFARNAGAR MEDICAL COLLEGE, MUZAFFARNAGAR (Private)',
        course: 'MBBS',
        quota: 'General',
        category: 'N/A',
        fees: '1393883',
        seats: '200',
      ),
      FeesSeatRow(
        sNo: 3,
        instituteAndType: 'EXAMPLE GOVERNMENT MEDICAL COLLEGE (Government)',
        course: 'MBBS',
        quota: 'General',
        category: 'N/A',
        fees: 'N/A',
        seats: '250',
      ),
      FeesSeatRow(
        sNo: 4,
        instituteAndType: 'ANOTHER PRIVATE MEDICAL COLLEGE, LUCKNOW (Private)',
        course: 'MBBS',
        quota: 'General',
        category: 'N/A',
        fees: '1850000',
        seats: '150',
      ),
      FeesSeatRow(
        sNo: 5,
        instituteAndType: 'DEEMED UNIVERSITY MEDICAL COLLEGE (Deemed)',
        course: 'MBBS',
        quota: 'General',
        category: 'N/A',
        fees: '2400000',
        seats: '100',
      ),
    ];
  }

  void setState(String v) => selectedState.value = v;
  void setInstituteType(String v) => selectedInstituteType.value = v;
  void setQuota(String v) => selectedQuota.value = v;
  void setCategory(String v) => selectedCategory.value = v;
  void setCourse(String v) => selectedCourse.value = v;
  void setYear(String v) => selectedYear.value = v;
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
              r.fees.contains(q) ||
              r.seats.contains(q),
        ),
      );
    }
  }
}
