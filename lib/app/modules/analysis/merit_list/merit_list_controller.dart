import 'package:get/get.dart';

class MeritListEntry {
  MeritListEntry({
    required this.sNo,
    required this.pdfName,
    required this.state,
    required this.year,
    required this.counsellingType,
  });

  final int sNo;
  final String pdfName;
  final String state;
  final String year;
  final String counsellingType;
}

class MeritListController extends GetxController {
  final RxString selectedState = 'Uttar Pradesh'.obs;
  final RxString selectedCounsellingType= 'State'.obs;
  final RxString selectedYear = '2024'.obs;
  final RxInt entriesPerPage = 10.obs;
  final RxString searchQuery = ''.obs;

  static const List<String> _states = [
    'Uttar Pradesh',
    'Madhya Pradesh',
    'Rajasthan',
    'Maharashtra',
  ];
  static const List<String> _counsellingTypes = ['State', 'MCC'];
  static const List<String> _years = ['2024', '2023', '2022', '2021'];
  static const List<int> _entriesOptions = [10, 25, 50];

  List<String> get states => _states;
  List<String> get counsellingTypes => _counsellingTypes;
  List<String> get years => _years;
  List<int> get entriesOptions => _entriesOptions;

  late final List<MeritListEntry> _allEntries;
  final RxList<MeritListEntry> filteredEntries = <MeritListEntry>[].obs;

  @override
  void onInit() {
    super.onInit();
    _allEntries = _buildSampleEntries();
    _applyFilters();
  }

  List<MeritListEntry> _buildSampleEntries() {
    return [
      MeritListEntry(
        sNo: 1,
        pdfName: 'UP STATE MERIT LIST OF NEET-UG (FIRST ROUND)',
        state: 'Uttar Pradesh',
        year: '2024',
        counsellingType: 'State',
      ),
      MeritListEntry(
        sNo: 2,
        pdfName: 'Merit List of Madhya Pradesh (Round 1)',
        state: 'Madhya Pradesh',
        year: '2024',
        counsellingType: 'State',
      ),
      MeritListEntry(
        sNo: 3,
        pdfName: 'Rajasthan NEET UG Merit List 2024',
        state: 'Rajasthan',
        year: '2024',
        counsellingType: 'State',
      ),
      MeritListEntry(
        sNo: 4,
        pdfName: 'UP STATE MERIT LIST OF NEET-UG (SECOND ROUND)',
        state: 'Uttar Pradesh',
        year: '2024',
        counsellingType: 'State',
      ),
      MeritListEntry(
        sNo: 5,
        pdfName: 'Maharashtra State Merit List NEET-UG 2024',
        state: 'Maharashtra',
        year: '2024',
        counsellingType: 'State',
      ),
    ];
  }

  void setState(String value) => selectedState.value = value;
  void setCounsellingType(String value) => selectedCounsellingType.value = value;
  void setYear(String value) => selectedYear.value = value;
  void setEntriesPerPage(int value) => entriesPerPage.value = value;
  void setSearchQuery(String value) {
    searchQuery.value = value;
    _applyFilters();
  }

  void _applyFilters() {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) {
      filteredEntries.assignAll(_allEntries);
    } else {
      filteredEntries.assignAll(
        _allEntries.where(
          (e) =>
              e.pdfName.toLowerCase().contains(q) ||
              e.state.toLowerCase().contains(q) ||
              e.year.contains(q) ||
              e.counsellingType.toLowerCase().contains(q),
        ),
      );
    }
  }

  void onCheckNow(MeritListEntry entry) {
    // Placeholder: open PDF or external link
  }
}
