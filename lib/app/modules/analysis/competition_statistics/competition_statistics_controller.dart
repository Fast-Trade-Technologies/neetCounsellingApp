import 'package:get/get.dart';

class CompetitionStatisticsController extends GetxController {
  final RxInt breakdownTabIndex = 0.obs;
  final RxString selectedYearNationality = '2025'.obs;
  final RxString selectedYearCategory = '2025'.obs;
  final RxString selectedYearGender = '2025'.obs;
  final RxString selectedState = 'All'.obs;
  final RxString selectedYearState = '2025'.obs;

  static const List<String> breakdownTabs = [
    'Candidates',
    'Nationality',
    'Gender',
    'Category',
    'Exam',
  ];
  static const List<String> years = ['2025', '2024', '2023', '2022', '2021', '2020', '2019'];
  static const List<String> states = ['All', 'Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka'];

  List<String> get yearsList => years;
  List<String> get statesList => states;

  void setBreakdownTab(int index) => breakdownTabIndex.value = index;
  void setYearNationality(String v) => selectedYearNationality.value = v;
  void setYearCategory(String v) => selectedYearCategory.value = v;
  void setYearGender(String v) => selectedYearGender.value = v;
  void setState(String v) => selectedState.value = v;
  void setYearState(String v) => selectedYearState.value = v;

  // Sample: row label, then per year (2019..2025): value, trend up/down, change
  static const List<Map<String, dynamic>> breakdownRows = [
    {
      'label': 'No. Of Candidates Registered',
      '2019': 1519375,
      '2020': 1597435,
      '2021': 1617557,
      '2022': 1873894,
      '2023': 2066389,
      '2024': 2406982,
      '2025': 2276069,
    },
    {
      'label': 'No. Of Candidates Present',
      '2019': 1417893,
      '2020': 1476651,
      '2021': 1550000,
      '2022': 1760000,
      '2023': 1950000,
      '2024': 2200000,
      '2025': 2209318,
    },
    {
      'label': 'No. Of Candidates Absent',
      '2019': 101482,
      '2020': 120784,
      '2021': 67557,
      '2022': 113894,
      '2023': 116389,
      '2024': 206982,
      '2025': 66751,
    },
  ];

  static const List<String> breakdownYears = ['2019', '2020', '2021', '2022', '2023', '2024', '2025'];

  // Yearly insights: year -> registered, appeared, qualified (in lakhs)
  static const List<Map<String, dynamic>> yearlyInsights = [
    {'year': '2019', 'registered': 15.2, 'appeared': 14.2, 'qualified': 7.9},
    {'year': '2020', 'registered': 16.0, 'appeared': 14.8, 'qualified': 8.6},
    {'year': '2021', 'registered': 16.2, 'appeared': 15.5, 'qualified': 8.9},
    {'year': '2022', 'registered': 18.7, 'appeared': 17.6, 'qualified': 9.9},
    {'year': '2023', 'registered': 20.7, 'appeared': 19.5, 'qualified': 11.2},
    {'year': '2024', 'registered': 24.1, 'appeared': 22.0, 'qualified': 12.1},
    {'year': '2025', 'registered': 22.8, 'appeared': 22.1, 'qualified': 12.4},
  ];

  // Nationality: label, registered, appeared, qualified (in lakhs)
  static const List<Map<String, dynamic>> nationalityData = [
    {'label': 'Indian', 'registered': 22.1, 'appeared': 21.5, 'qualified': 12.0},
    {'label': 'NRI', 'registered': 0.45, 'appeared': 0.42, 'qualified': 0.28},
    {'label': 'OCI', 'registered': 0.25, 'appeared': 0.22, 'qualified': 0.12},
  ];

  // Category: label, registered (lakhs), qualified (lakhs)
  static const List<Map<String, dynamic>> categoryData = [
    {'label': 'General', 'registered': 10.2, 'qualified': 4.8},
    {'label': 'OBC', 'registered': 6.1, 'qualified': 3.2},
    {'label': 'EWS', 'registered': 2.4, 'qualified': 1.1},
    {'label': 'SC', 'registered': 2.8, 'qualified': 1.8},
    {'label': 'ST', 'registered': 1.3, 'qualified': 0.5},
  ];

  // Gender: label, count (lakhs)
  static const List<Map<String, dynamic>> genderData = [
    {'label': 'Female', 'value': 12.8},
    {'label': 'Male', 'value': 9.3},
  ];

  // State-wise: label, registered (lakhs)
  static const List<Map<String, dynamic>> stateWiseData = [
    {'label': 'UP', 'registered': 3.2, 'appeared': 3.0, 'qualified': 1.6},
    {'label': 'Maharashtra', 'registered': 2.8, 'appeared': 2.7, 'qualified': 1.4},
    {'label': 'Rajasthan', 'registered': 2.1, 'appeared': 2.0, 'qualified': 1.0},
    {'label': 'Karnataka', 'registered': 1.8, 'appeared': 1.7, 'qualified': 0.9},
    {'label': 'Others', 'registered': 12.9, 'appeared': 12.7, 'qualified': 7.5},
  ];
}
