import 'package:get/get.dart';

import '../bindings/college_seats_binding.dart';
import '../bindings/cutoff_allotments_binding.dart';
import '../bindings/initial_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/main_binding.dart';
import '../bindings/register_binding.dart';
import '../bindings/menu_binding.dart';
import '../bindings/seat_distribution_binding.dart';
import '../bindings/sycc_report_binding.dart';
import '../modules/analysis/college_seats/college_seats_view.dart';
import '../modules/analysis/seat_distribution/seat_distribution_view.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/register/register_view.dart';
import '../modules/main/main_view.dart';
import '../modules/more/menu/menu_view.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/post_exam/sycc_report/sycc_report_view.dart';
import '../modules/tools/cutoff_allotments/cutoff_allotments_view.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingView(),
      binding: InitialBinding(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const MainView(),
      binding: MainBinding(),
    ),
    GetPage(
      name: AppRoutes.analysisCollegeSeats,
      page: () => const CollegeSeatsView(),
      binding: CollegeSeatsBinding(),
    ),
    GetPage(
      name: AppRoutes.analysisSeatDistribution,
      page: () => const SeatDistributionView(),
      binding: SeatDistributionBinding(),
    ),
    GetPage(
      name: AppRoutes.toolsCutoffAllotments,
      page: () => const CutoffAllotmentsView(),
      binding: CutoffAllotmentsBinding(),
    ),
    GetPage(
      name: AppRoutes.syccReport,
      page: () => const SyccReportView(),
      binding: SyccReportBinding(),
    ),
    GetPage(
      name: AppRoutes.moreMenu,
      page: () => const MenuView(),
      binding: MenuBinding(),
    ),
  ];
}

