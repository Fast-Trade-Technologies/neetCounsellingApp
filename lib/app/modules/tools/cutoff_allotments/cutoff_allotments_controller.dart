import 'package:get/get.dart';

class CutoffAllotmentsController extends GetxController {
  final RxBool showResults = false.obs;

  void submit() => showResults.value = true;
}
