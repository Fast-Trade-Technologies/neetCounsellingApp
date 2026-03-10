import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CollegeSeatsController extends GetxController {
  final RxInt selectedTab = 0.obs; // 0 = Seat Wise, 1 = College Wise

  /// Controls pan/zoom for the SVG map.
  final TransformationController mapTransformController = TransformationController();
  double _currentScale = 1.0;

  @override
  Future<void> refresh() async {}

  void setTab(int index) => selectedTab.value = index;

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
}
