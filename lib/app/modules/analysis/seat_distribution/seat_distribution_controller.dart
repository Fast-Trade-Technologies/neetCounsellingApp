import 'package:get/get.dart';

class SeatDistributionController extends GetxController {
  final RxBool showResults = false.obs;

  void submit() => showResults.value = true;
}
