import 'package:get/get.dart';

import '../../../../api_services/checklist_api.dart';
import '../../../../api_services/filters_api.dart';
import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/utils/url_launcher_util.dart';

class ChecklistDocument {
  ChecklistDocument({
    required this.sNo,
    required this.documentName,
    required this.documentType,
    this.sampleAvailable = false,
    this.sampleFile,
  });

  final int sNo;
  final String documentName;
  final String documentType;
  final bool sampleAvailable;
  final String? sampleFile;

  factory ChecklistDocument.fromJson(Map<String, dynamic> json) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    final sampleAvailable = json['sample_available'] == true;
    return ChecklistDocument(
      sNo: toInt(json['s_no'] ?? json['id']),
      documentName: json['document_name']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? 'required',
      sampleAvailable: sampleAvailable,
      sampleFile: json['sample_file']?.toString(),
    );
  }
}

class ChecklistSampleController extends GetxController {
  final RxString selectedState = 'Uttar Pradesh'.obs;
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxBool generalExpanded = true.obs;
  final RxBool specialExpanded = false.obs;
  final RxBool nriExpanded = false.obs;
  final RxBool ocipioExpanded = false.obs;

  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  List<String> get states => stateFilters.isEmpty
      ? ['Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka', 'Gujarat']
      : stateFilters.map((e) => e.name).toList();

  final RxList<ChecklistDocument> generalDocuments = <ChecklistDocument>[].obs;
  final RxList<ChecklistDocument> specialCategoryDocuments = <ChecklistDocument>[].obs;
  final RxList<ChecklistDocument> nriDocuments = <ChecklistDocument>[].obs;
  final RxList<ChecklistDocument> ocipioDocuments = <ChecklistDocument>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadChecklist();
    _loadStateFilters();
  }

  Future<void> _loadStateFilters() async {
    final (success, stateList, _) = await FiltersApi.getStates(showLoader: false);
    if (success && stateList.isNotEmpty) stateFilters.assignAll(stateList);
  }

  @override
  Future<void> refresh() async => loadChecklist(showLoader: false);

  Future<void> loadChecklist({bool showLoader = true}) async {
    error.value = '';
    isLoading.value = true;
    final (success, data, errorMessage) = await ChecklistApi.getChecklistSample(
      showLoader: showLoader,
      extraQuery: null,
    );
    isLoading.value = false;

    if (!success || data == null) {
      error.value = errorMessage ?? 'Failed to load checklist';
      AppSnackbar.error('Checklist', error.value);
      generalDocuments.clear();
      specialCategoryDocuments.clear();
      nriDocuments.clear();
      ocipioDocuments.clear();
      return;
    }

    final raw = data['checklist'];
    final docs = <ChecklistDocument>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is Map) {
          docs.add(ChecklistDocument.fromJson(Map<String, dynamic>.from(e)));
        }
      }
    }

    // Map API types to UI sections (fallbacks are best-effort).
    generalDocuments.assignAll(docs.where((d) => d.documentType.toLowerCase() == 'required'));
    specialCategoryDocuments.assignAll(docs.where((d) => d.documentType.toLowerCase() == 'special'));
    nriDocuments.assignAll(docs.where((d) => d.documentType.toLowerCase() == 'nri'));
    ocipioDocuments.assignAll(docs.where((d) => d.documentType.toLowerCase() == 'ocipio'));

    // If backend doesn't provide these buckets yet, keep everything in General.
    if (specialCategoryDocuments.isEmpty && nriDocuments.isEmpty && ocipioDocuments.isEmpty) {
      generalDocuments.assignAll(docs);
    }
  }

  void setState(String v) => selectedState.value = v;
  void setSearchQuery(String value) => searchQuery.value = value;

  void toggleGeneral() => generalExpanded.value = !generalExpanded.value;
  void toggleSpecial() => specialExpanded.value = !specialExpanded.value;
  void toggleNri() => nriExpanded.value = !nriExpanded.value;
  void toggleOcipio() => ocipioExpanded.value = !ocipioExpanded.value;

  List<ChecklistDocument> filtered(List<ChecklistDocument> list) {
    final q = searchQuery.value.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((d) => d.documentName.toLowerCase().contains(q)).toList();
  }

  Future<void> openSample(ChecklistDocument doc) async {
    if (!doc.sampleAvailable || (doc.sampleFile?.trim().isEmpty ?? true)) {
      AppSnackbar.info('Sample View', 'Sample not available for "${doc.documentName}".');
      return;
    }
    await openLinkInBrowser(doc.sampleFile);
  }
}
