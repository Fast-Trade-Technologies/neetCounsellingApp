import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CollegeSeatsController extends GetxController {
  final RxInt selectedTab = 0.obs; // 0 = Seat Wise, 1 = College Wise

  /// Controls pan/zoom for the SVG map (kept for future use).
  final TransformationController mapTransformController = TransformationController();
  double _currentScale = 1.0;

  /// Hard-coded state seats data (from API response) for this screen.
  final Map<String, int> _stateSeatByCode = const {
    'in-ap': 5784,
    'in-ar': 85,
    'in-as': 1377,
    'in-br': 2442,
    'in-cg': 1890,
    'in-ga': 153,
    'in-gj': 5386,
    'in-hr': 1609,
    'in-hp': 762,
    'in-jh': 578,
    'in-ka': 7052,
    'in-kl': 3828,
    'in-mp': 4560,
    'in-mh': 8585,
    'in-mn': 322,
    'in-ml': 192,
    'in-mz': 85,
    'in-nl': 85,
    'in-or': 1367,
    'in-pb': 1537,
    'in-rj': 5420,
    'in-tn': 8785,
    'in-tg': 5946,
    'in-tr': 377,
    'in-up': 10868,
    'in-ut': 985,
    'in-wb': 4438,
    'in-an': 98,
    'in-ch': 127,
    'in-dnhdd': 128,
    'in-dl': 162,
    'in-py': 830,
    'in-jk': 1011,
  };

  /// Currently selected state (human readable).
  final RxString _selectedStateName = ''.obs;

  /// Exposed getters used by the view.
  List<String> get stateNames {
    final names = _stateSeatByCode.keys.map(_stateNameFromCode).toList();
    names.sort();
    return names;
  }

  String get selectedStateName => _selectedStateName.value;

  int get selectedStateSeats {
    if (_selectedStateName.value.isEmpty) return 0;
    String? codeMatch;
    _stateSeatByCode.forEach((code, _) {
      if (_stateNameFromCode(code) == _selectedStateName.value) {
        codeMatch = code;
      }
    });
    if (codeMatch == null) return 0;
    return _stateSeatByCode[codeMatch] ?? 0;
  }

  @override
  void onInit() {
    super.onInit();
    // Default selected state: Uttar Pradesh if available, else first state.
    final names = stateNames;
    if (names.isEmpty) return;
    if (names.any((e) => e.toLowerCase().contains('uttar pradesh'))) {
      _selectedStateName.value =
          names.firstWhere((e) => e.toLowerCase().contains('uttar pradesh'));
    } else {
      _selectedStateName.value = names.first;
    }
  }

  @override
  Future<void> refresh() async {
    // No-op for now; data is static.
  }

  void setTab(int index) => selectedTab.value = index;

  void setSelectedState(String stateName) {
    _selectedStateName.value = stateName;
  }

  void resetMapView() {
    _currentScale = 1.0;
    mapTransformController.value = Matrix4.identity();
  }

  void zoomIn() {
    _setScale(_currentScale * 1.2);
  }

  void zoomOut() {
    _setScale(_currentScale / 1.2);
  }

  void _setScale(double scale) {
    final clamped = scale.clamp(0.8, 4.0);
    _currentScale = clamped;
    mapTransformController.value = Matrix4.identity()..scale(_currentScale);
  }

  @override
  void onClose() {
    mapTransformController.dispose();
    super.onClose();
  }

  String _stateNameFromCode(String code) {
    const stateMap = {
      'in-up': 'Uttar Pradesh',
      'in-mh': 'Maharashtra',
      'in-rj': 'Rajasthan',
      'in-ka': 'Karnataka',
      'in-tn': 'Tamil Nadu',
      'in-gj': 'Gujarat',
      'in-wb': 'West Bengal',
      'in-mp': 'Madhya Pradesh',
      'in-br': 'Bihar',
      'in-ap': 'Andhra Pradesh',
      'in-tg': 'Telangana',
      'in-kl': 'Kerala',
      'in-or': 'Odisha',
      'in-pb': 'Punjab',
      'in-hr': 'Haryana',
      'in-jh': 'Jharkhand',
      'in-ch': 'Chandigarh',
      'in-dl': 'Delhi',
      'in-hp': 'Himachal Pradesh',
      'in-ut': 'Uttarakhand',
      'in-jk': 'Jammu & Kashmir',
      'in-as': 'Assam',
      'in-an': 'Andaman & Nicobar',
      'in-ar': 'Arunachal Pradesh',
      'in-mn': 'Manipur',
      'in-ml': 'Meghalaya',
      'in-mz': 'Mizoram',
      'in-nl': 'Nagaland',
      'in-sk': 'Sikkim',
      'in-tr': 'Tripura',
      'in-ga': 'Goa',
      'in-py': 'Puducherry',
      'in-dnhdd': 'Dadra & Nagar Haveli',
      'in-cg': 'Chhattisgarh',
    };
    return stateMap[code.toLowerCase()] ?? code.toUpperCase();
  }
}
