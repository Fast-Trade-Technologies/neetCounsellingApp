import 'package:get/get.dart';

import '../../../../api_services/filters_api.dart';

class UniversitiesInstitutesRow {
  UniversitiesInstitutesRow({
    required this.sNo,
    required this.instituteAndType,
    required this.university,
    required this.authority,
    required this.bondPenalty,
    required this.bedsCount,
    this.officialWebsiteUrl,
    this.registrationUrl,
    this.prospectsUrl,
  });

  final int sNo;
  final String instituteAndType;
  final String university;
  final String authority;
  final String bondPenalty;
  final String bedsCount;
  final String? officialWebsiteUrl;
  final String? registrationUrl;
  final String? prospectsUrl;
}

class UniversitiesInstitutesController extends GetxController {
  final RxString selectedState = 'Uttar Pradesh'.obs;
  final RxString selectedInstituteType = 'Select Institute Type'.obs;
  final RxString selectedUniversity = 'Select University'.obs;
  final RxString searchQuery = ''.obs;

  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  List<String> get states => stateFilters.isEmpty
      ? ['Select State', 'Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka', 'Gujarat']
      : ['Select State', ...stateFilters.map((e) => e.name)];

  static const List<String> instituteTypes = [
    'Select Institute Type',
    'Government',
    'Private',
    'Deemed',
  ];
  static const List<String> universities = [
    'Select University',
    'Sharda University Greater Noida UP',
    'Dr. Ram Manohar Lohia Avadh University',
    'Chhatrapati Shahuji Maharaj University',
    'Other University',
  ];

  late final List<UniversitiesInstitutesRow> _allRows;
  final RxList<UniversitiesInstitutesRow> filteredRows = <UniversitiesInstitutesRow>[].obs;

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

  List<UniversitiesInstitutesRow> _buildSampleRows() {
    return [
      UniversitiesInstitutesRow(
        sNo: 1,
        instituteAndType: 'SCHOOL OF MEDICAL SCIENCES (SHARDA UNIVERSITY) G.NOIDA (Private)',
        university: 'Sharda University Greater Noida UP',
        authority: 'Directorate General of Medical Education and Training',
        bondPenalty: 'NIL',
        bedsCount: '1200',
        officialWebsiteUrl: 'https://example.com',
        registrationUrl: 'https://example.com/reg',
        prospectsUrl: 'https://example.com/prospects',
      ),
      UniversitiesInstitutesRow(
        sNo: 2,
        instituteAndType: 'SRI RAM MURTI SMARAK INSTITUTE OF MEDICAL SCIENCES, BAREILLY (Private)',
        university: 'Dr. Ram Manohar Lohia Avadh University',
        authority: 'Directorate General of Medical Education and Training',
        bondPenalty: 'NIL',
        bedsCount: '750',
      ),
      UniversitiesInstitutesRow(
        sNo: 3,
        instituteAndType: 'MUZAFFARNAGAR MEDICAL COLLEGE, MUZAFFARNAGAR (Private)',
        university: 'Chhatrapati Shahuji Maharaj University',
        authority: 'Directorate of Medical Education',
        bondPenalty: 'As per norms',
        bedsCount: '500',
      ),
      UniversitiesInstitutesRow(
        sNo: 4,
        instituteAndType: 'EXAMPLE GOVERNMENT MEDICAL COLLEGE (Government)',
        university: 'State Medical University',
        authority: 'State Health University',
        bondPenalty: 'NIL',
        bedsCount: '1500',
      ),
      UniversitiesInstitutesRow(
        sNo: 5,
        instituteAndType: 'DEEMED UNIVERSITY MEDICAL COLLEGE (Deemed)',
        university: 'Deemed University',
        authority: 'UGC / MCI',
        bondPenalty: 'NIL',
        bedsCount: '800',
      ),
    ];
  }

  void setState(String v) => selectedState.value = v;
  void setInstituteType(String v) => selectedInstituteType.value = v;
  void setUniversity(String v) => selectedUniversity.value = v;
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
              r.university.toLowerCase().contains(q) ||
              r.authority.toLowerCase().contains(q) ||
              r.bondPenalty.toLowerCase().contains(q) ||
              r.bedsCount.contains(q),
        ),
      );
    }
  }
}
