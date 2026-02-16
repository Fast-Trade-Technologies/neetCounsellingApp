import 'package:get/get.dart';

class SeatDistributionController extends GetxController {
  final RxBool showResults = false.obs;

  Future<void> refresh() async {}

  void submit() => showResults.value = true;
}
