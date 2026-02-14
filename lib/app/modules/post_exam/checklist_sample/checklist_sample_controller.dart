import 'package:get/get.dart';

class ChecklistDocument {
  ChecklistDocument({required this.sNo, required this.documentName});

  final int sNo;
  final String documentName;
}

class ChecklistSampleController extends GetxController {
  final RxString selectedState = 'Uttar Pradesh'.obs;
  final RxString searchQuery = ''.obs;

  final RxBool generalExpanded = true.obs;
  final RxBool specialExpanded = false.obs;
  final RxBool nriExpanded = false.obs;
  final RxBool ocipioExpanded = false.obs;

  static const List<String> states = [
    'Uttar Pradesh',
    'Maharashtra',
    'Rajasthan',
    'Karnataka',
    'Gujarat',
  ];

  late final List<ChecklistDocument> generalDocuments;
  late final List<ChecklistDocument> specialCategoryDocuments;
  late final List<ChecklistDocument> nriDocuments;
  late final List<ChecklistDocument> ocipioDocuments;

  @override
  void onInit() {
    super.onInit();
    generalDocuments = _buildGeneralDocuments();
    specialCategoryDocuments = _buildSpecialCategoryDocuments();
    nriDocuments = [];
    ocipioDocuments = [];
  }

  List<ChecklistDocument> _buildGeneralDocuments() {
    const names = [
      'Class 10th Marksheet',
      'NEET UG Application Form Slip',
      'Student Aadhar Card',
      'Passport Size Photograph',
      'Gap Certificate',
      'Class 12th Marksheet',
      'Category Certificate (if applicable)',
      'Domicile Certificate',
      'Provisional Allotment Letter',
      'Identity Proof',
      'Parent\'s Aadhar Card',
      'Transfer Certificate',
      'Character Certificate',
      'Medical Fitness Certificate',
      'Anti-Ragging Affidavit',
      'Undertaking by Candidate',
      'Fee Payment Receipt',
      'Seat Leaving Certificate (if applicable)',
    ];
    return List.generate(names.length, (i) => ChecklistDocument(sNo: i + 1, documentName: names[i]));
  }

  List<ChecklistDocument> _buildSpecialCategoryDocuments() {
    const names = [
      'PwD Certificate',
      'EWS Certificate',
      'OBC-NCL Certificate',
      'SC Certificate',
      'ST Certificate',
      'Kashmiri Migrant Certificate',
    ];
    return List.generate(names.length, (i) => ChecklistDocument(sNo: i + 1, documentName: names[i]));
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
}
