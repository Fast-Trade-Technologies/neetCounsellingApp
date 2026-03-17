import 'package:get/get.dart';

import '../../../../api_services/checklist_api.dart';
import '../../../../api_services/filters_api.dart';
import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/widgets/pdf_webview_page.dart';

class ChecklistDocument {
  ChecklistDocument({
    required this.sNo,
    required this.documentName,
    required this.documentType,
    this.sampleAvailable = false,
    this.sampleFile,
    this.isLocked = false,
  });

  final int sNo;
  final String documentName;
  final String documentType;
  final bool sampleAvailable;
  final String? sampleFile;
  final bool isLocked;

  /// From API document object: s_no, document_name, sample_file, has_sample, is_locked
  factory ChecklistDocument.fromJson(Map<String, dynamic> json, {String documentType = 'required'}) {
    int toInt(dynamic v) => v is int ? v : int.tryParse(v?.toString() ?? '') ?? 0;
    final hasSample = json['has_sample'] == true || json['sample_available'] == true;
    final sampleFile = json['sample_file']?.toString().trim();
    return ChecklistDocument(
      sNo: toInt(json['s_no'] ?? json['sNo'] ?? json['id']),
      documentName: (json['document_name']?.toString() ?? '').trim(),
      documentType: (json['document_type']?.toString() ?? documentType).trim(),
      sampleAvailable: hasSample && (sampleFile?.isNotEmpty ?? false),
      sampleFile: sampleFile?.isEmpty ?? true ? null : sampleFile,
      isLocked: json['is_locked'] == true,
    );
  }
}

class ChecklistSampleController extends GetxController {
  final RxString selectedState = 'Select State'.obs;
  final RxString selectedStateId = ''.obs;
  final RxString searchQuery = ''.obs;

  final RxBool isLoading = false.obs;
  final RxString error = ''.obs;

  final RxBool generalExpanded = true.obs;
  final RxBool specialExpanded = false.obs;
  final RxBool nriExpanded = false.obs;
  final RxBool ocipioExpanded = false.obs;

  final RxList<FilterItem> stateFilters = <FilterItem>[].obs;
  List<String> get states => stateFilters.isEmpty
      ? ['Select State', 'Uttar Pradesh', 'Maharashtra', 'Rajasthan', 'Karnataka', 'Gujarat']
      : ['Select State', ...stateFilters.map((e) => e.name)];

  final RxList<ChecklistDocument> generalDocuments = <ChecklistDocument>[].obs;
  final RxList<ChecklistDocument> specialCategoryDocuments = <ChecklistDocument>[].obs;
  final RxList<ChecklistDocument> nriDocuments = <ChecklistDocument>[].obs;
  final RxList<ChecklistDocument> ocipioDocuments = <ChecklistDocument>[].obs;

  int get totalDocumentCount =>
      generalDocuments.length + specialCategoryDocuments.length +
      nriDocuments.length + ocipioDocuments.length;

  @override
  void onInit() {
    super.onInit();
    _loadStateFilters();
  }

  Future<void> _loadStateFilters() async {
    final (success, stateList, _) = await FiltersApi.getStates(showLoader: false);
    if (success && stateList.isNotEmpty) {
      stateFilters.assignAll(stateList);
      if (selectedStateId.value.isEmpty) {
        // Set default state to Uttar Pradesh
        final upState = stateList.where((e) => 
          e.name.toLowerCase().contains('uttar pradesh') || 
          e.name.toLowerCase().contains('up') ||
          e.name.toLowerCase() == 'up'
        ).toList();
        if (upState.isNotEmpty) {
          selectedState.value = upState.first.name;
          selectedStateId.value = upState.first.id;
        } else if (stateList.isNotEmpty) {
          selectedState.value = stateList.first.name;
          selectedStateId.value = stateList.first.id;
        }
        loadChecklist(showLoader: false);
      }
    } else {
      selectedState.value = 'Uttar Pradesh';
      selectedStateId.value = '2';
      loadChecklist(showLoader: false);
    }
  }

  @override
  Future<void> refresh() async => loadChecklist(showLoader: false);

  Future<void> loadChecklist({bool showLoader = true}) async {
    error.value = '';
    isLoading.value = true;
    final (success, data, errorMessage) = await ChecklistApi.getChecklistSample(
      stateId: selectedStateId.value.isEmpty ? null : selectedStateId.value,
      showLoader: showLoader,
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

    final stateName = data['selected_state_name']?.toString().trim();
    if (stateName != null && stateName.isNotEmpty) {
      selectedState.value = stateName;
    }

    // API response: data.document_types = [{ type_id, type_name, total_count, documents: [...] }]
    final rawTypes = data['document_types'];
    generalDocuments.clear();
    specialCategoryDocuments.clear();
    nriDocuments.clear();
    ocipioDocuments.clear();

    if (rawTypes is List) {
      for (final typeEntry in rawTypes) {
        if (typeEntry is! Map) continue;
        final map = Map<String, dynamic>.from(typeEntry);
        final typeName = (map['type_name']?.toString() ?? '').trim().toUpperCase();
        final typeId = map['type_id'] is int ? map['type_id'] as int : int.tryParse(map['type_id']?.toString() ?? '') ?? 0;
        final docsRaw = map['documents'];
        final list = <ChecklistDocument>[];
        if (docsRaw is List) {
          for (final e in docsRaw) {
            if (e is Map) {
              list.add(ChecklistDocument.fromJson(
                Map<String, dynamic>.from(e),
                documentType: typeName.isNotEmpty ? typeName : 'GENERAL',
              ));
            }
          }
        }
        if (typeId == 1 || typeName.contains('GENERAL')) {
          generalDocuments.assignAll(list);
        } else if (typeId == 2 || typeName.contains('SPECIAL')) {
          specialCategoryDocuments.assignAll(list);
        } else if (typeId == 3 || typeName.contains('NRI')) {
          nriDocuments.assignAll(list);
        } else if (typeId == 4 || typeName.contains('OCIPIO')) {
          ocipioDocuments.assignAll(list);
        }
      }
    }

    // Fallback: legacy flat data.checklist
    if (generalDocuments.isEmpty && specialCategoryDocuments.isEmpty && nriDocuments.isEmpty && ocipioDocuments.isEmpty) {
      final raw = data['checklist'];
      if (raw is List) {
        for (final e in raw) {
          if (e is Map) {
            generalDocuments.add(ChecklistDocument.fromJson(Map<String, dynamic>.from(e)));
          }
        }
      }
    }
  }

  void setState(String v) {
    selectedState.value = v;
    if (v == 'Select State') {
      selectedStateId.value = '';
      generalDocuments.clear();
      specialCategoryDocuments.clear();
      nriDocuments.clear();
      ocipioDocuments.clear();
      return;
    }
    final match = stateFilters.where((e) => e.name == v).toList();
    selectedStateId.value = match.isEmpty ? '' : match.first.id;
    loadChecklist(showLoader: false);
  }
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
    if (doc.isLocked) {
      AppSnackbar.info('Sample View', 'This sample is locked.');
      return;
    }
    if (!doc.sampleAvailable || (doc.sampleFile?.trim().isEmpty ?? true)) {
      AppSnackbar.info('Sample View', 'Sample not available for "${doc.documentName}".');
      return;
    }
    // Clean up URL coming from API (may contain escaped slashes like http:\/\/...)
    var url = doc.sampleFile!.trim();
    url = url.replaceAll(r'\/', '/');
    if (url.isEmpty) {
      AppSnackbar.info('Sample View', 'Sample URL is invalid.');
      return;
    }
    Get.to(() => PdfWebViewPage(
          url: url,
          title: doc.documentName,
        ));
  }
}
