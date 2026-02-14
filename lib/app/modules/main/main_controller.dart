import 'package:get/get.dart';

class MainController extends GetxController {
  final RxInt currentIndex = 0.obs;

  void setIndex(int index) => currentIndex.value = index;

  @override
  void onReady() {
    super.onReady();
    final args = Get.arguments;
    if (args != null && args is int && args >= 0 && args <= 3) {
      currentIndex.value = args;
    }
  }
}
