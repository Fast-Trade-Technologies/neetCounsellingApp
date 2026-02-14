import 'package:get/get.dart';

import '../bindings/college_seats_binding.dart';
import '../bindings/cutoff_allotments_binding.dart';
import '../bindings/college_ranking_binding.dart';
import '../bindings/counselling_binding.dart';
import '../bindings/fees_seat_matrix_binding.dart';
import '../bindings/universities_institutes_binding.dart';
import '../bindings/initial_binding.dart';
import '../bindings/login_binding.dart';
import '../bindings/otp_binding.dart';
import '../bindings/splash_binding.dart';
import '../bindings/main_binding.dart';
import '../bindings/register_binding.dart';
import '../bindings/menu_binding.dart';
import '../bindings/profile_binding.dart';
import '../bindings/competition_statistics_binding.dart';
import '../bindings/courses_binding.dart';
import '../bindings/merit_list_binding.dart';
import '../bindings/checklist_sample_binding.dart';
import '../bindings/seat_distribution_binding.dart';
import '../bindings/sycc_report_binding.dart';
import '../modules/analysis/college_seats/college_seats_view.dart';
import '../modules/analysis/competition_statistics/competition_statistics_view.dart';
import '../modules/analysis/courses/courses_view.dart';
import '../modules/dashboard/book_now_view.dart';
import '../modules/dashboard/content_detail_view.dart';
import '../modules/dashboard/counselling_links_view.dart';
import '../modules/dashboard/important_links_view.dart';
import '../modules/dashboard/news_list_view.dart';
import '../modules/dashboard/webinars_view.dart';
import '../modules/analysis/merit_list/merit_list_view.dart';
import '../modules/analysis/seat_distribution/seat_distribution_view.dart';
import '../modules/auth/login/login_view.dart';
import '../modules/auth/otp/otp_view.dart';
import '../modules/auth/register/register_view.dart';
import '../modules/splash/splash_view.dart';
import '../modules/main/main_view.dart';
import '../modules/more/menu/menu_view.dart';
import '../modules/more/profile/profile_view.dart';
import '../modules/onboarding/onboarding_view.dart';
import '../modules/post_exam/checklist_sample/checklist_sample_view.dart';
import '../modules/post_exam/sycc_report/sycc_report_view.dart';
import '../modules/tools/college_ranking/college_ranking_view.dart';
import '../modules/tools/counselling/counselling_view.dart';
import '../modules/tools/cutoff_allotments/cutoff_allotments_view.dart';
import '../modules/tools/fees_seat_matrix/fees_seat_matrix_view.dart';
import '../modules/tools/universities_institutes/universities_institutes_view.dart';
import 'app_routes.dart';

class AppPages {
  const AppPages._();

  static final pages = <GetPage<dynamic>>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
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
      name: AppRoutes.otp,
      page: () => const OtpView(),
      binding: OtpBinding(),
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
      name: AppRoutes.analysisMeritList,
      page: () => const MeritListView(),
      binding: MeritListBinding(),
    ),
    GetPage(
      name: AppRoutes.analysisCompetitionStatistics,
      page: () => const CompetitionStatisticsView(),
      binding: CompetitionStatisticsBinding(),
    ),
    GetPage(
      name: AppRoutes.analysisCourses,
      page: () => const CoursesView(),
      binding: CoursesBinding(),
    ),
    GetPage(
      name: AppRoutes.toolsCutoffAllotments,
      page: () => const CutoffAllotmentsView(),
      binding: CutoffAllotmentsBinding(),
    ),
    GetPage(
      name: AppRoutes.toolsFeesSeatMatrix,
      page: () => const FeesSeatMatrixView(),
      binding: FeesSeatMatrixBinding(),
    ),
    GetPage(
      name: AppRoutes.toolsCollegeRanking,
      page: () => const CollegeRankingView(),
      binding: CollegeRankingBinding(),
    ),
    GetPage(
      name: AppRoutes.toolsCounselling,
      page: () => const CounsellingView(),
      binding: CounsellingBinding(),
    ),
    GetPage(
      name: AppRoutes.toolsUniversitiesInstitutes,
      page: () => const UniversitiesInstitutesView(),
      binding: UniversitiesInstitutesBinding(),
    ),
    GetPage(
      name: AppRoutes.syccReport,
      page: () => const SyccReportView(),
      binding: SyccReportBinding(),
    ),
    GetPage(
      name: AppRoutes.postExamChecklistSample,
      page: () => const ChecklistSampleView(),
      binding: ChecklistSampleBinding(),
    ),
    GetPage(
      name: AppRoutes.moreMenu,
      page: () => const MenuView(),
      binding: MenuBinding(),
    ),
    GetPage(
      name: AppRoutes.profile,
      page: () => const ProfileView(),
      binding: ProfileBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboardBookNow,
      page: () => const BookNowView(),
    ),
    GetPage(
      name: AppRoutes.dashboardNews,
      page: () => const NewsListView(),
    ),
    GetPage(
      name: AppRoutes.dashboardCounsellingLinks,
      page: () => const CounsellingLinksView(),
    ),
    GetPage(
      name: AppRoutes.dashboardWebinars,
      page: () => const WebinarsView(),
    ),
    GetPage(
      name: AppRoutes.dashboardImportantLinks,
      page: () => const ImportantLinksView(),
    ),
    GetPage(
      name: AppRoutes.contentDetail,
      page: () => const ContentDetailView(),
    ),
  ];
}

