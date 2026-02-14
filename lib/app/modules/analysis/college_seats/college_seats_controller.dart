import 'package:get/get.dart';

class CollegeSeatsController extends GetxController {
  final RxInt selectedTab = 0.obs; // 0 = Seat Wise, 1 = College Wise

  void setTab(int index) => selectedTab.value = index;
}
