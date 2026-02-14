import 'package:get/get.dart';

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
  final RxString selectedStateType = 'Select State Type'.obs;
  final RxString selectedState = 'All State'.obs;
  final RxString searchQuery = ''.obs;

  static const List<String> counsellingTypes = [
    'Select Counselling Type',
    'State',
    'MCC',
    'Deemed',
    'Central',
  ];
  static const List<String> stateTypes = [
    'Select State Type',
    'Open State',
    'Closed State',
  ];
  static const List<String> states = [
    'All State',
    'Gujarat',
    'Andaman and Nicobar Islands',
    'Uttar Pradesh',
    'Maharashtra',
    'Rajasthan',
  ];

  late final List<CounsellingRow> _allRows;
  final RxList<CounsellingRow> filteredRows = <CounsellingRow>[].obs;

  @override
  void onInit() {
    super.onInit();
    _allRows = _buildSampleRows();
    _applyFilters();
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

  void setCounsellingType(String v) => selectedCounsellingType.value = v;
  void setStateType(String v) => selectedStateType.value = v;
  void setState(String v) => selectedState.value = v;
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
