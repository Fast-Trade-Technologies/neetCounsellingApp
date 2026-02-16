import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/menu_grid_button.dart';
import '../../core/widgets/welcome_card.dart';
import '../../core/storage/app_storage.dart';
import '../../routes/app_routes.dart';
import 'main_controller.dart';

class MainView extends GetView<MainController> {
  const MainView({super.key});

  static const String _icons = 'assets/dashboard-icons';

  static const List<_NavItem> _navItems = [
    _NavItem(label: 'Dashboard', icon: Icons.home_rounded, iconAsset: null),
    _NavItem(label: 'Analysis', icon: Icons.show_chart_rounded, iconAsset: null),
    _NavItem(label: 'Tools', icon: Icons.build_rounded, iconAsset: null),
    _NavItem(label: 'Post-Exam', icon: Icons.school_rounded, iconAsset: null),
  ];

  static const List<String> _titles = [
    'Dashboard',
    'Analysis',
    'Tools',
    'Post-Exam',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(72.h),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.headerBg,
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.06),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          padding: EdgeInsets.fromLTRB(18.w, 10.h, 18.w, 14.h),
          child: SafeArea(
            bottom: false,
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.toNamed(AppRoutes.moreMenu),
                    borderRadius: BorderRadius.circular(8.r),
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 4.h),
                      child: Row(
                        children: [
                          Icon(Icons.person_outline_rounded,
                              size: 40.w, color: AppColors.primaryBlue),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  AppStorage.userName?.trim().isNotEmpty == true
                                      ? AppStorage.userName!.trim()
                                      : 'User',
                                  style: AppTextStyles.titleM.copyWith(
                                    fontSize: 16.sp,
                                    color: AppColors.textDark,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  AppStorage.userEmail ?? '',
                                  style: AppTextStyles.bodyS.copyWith(
                                    fontSize: 11.sp,
                                    color: AppColors.textMuted,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Obx(
                  () => Text(
                    _titles[controller.currentIndex.value],
                    style: AppTextStyles.mainScreenTitle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 18.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WelcomeCard(
              bookNowImageAsset: 'assets/dashboard/dashboard-banner.png',
              onBookNow: _onBookNow,
            ),
            SizedBox(height: 20.h),
            Obx(() => _buildTabContent(controller.currentIndex.value)),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.navBarBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(
                  _navItems.length,
                  (i) => _NavBarItem(
                    label: _navItems[i].label,
                    icon: _navItems[i].icon,
                    iconAsset: _navItems[i].iconAsset,
                    isSelected: controller.currentIndex.value == i,
                    onTap: () => controller.setIndex(i),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  static void _onBookNow() => Get.toNamed(AppRoutes.dashboardBookNow);

  Widget _buildTabContent(int index) {
    switch (index) {
      case 0:
        return _DashboardContent(controller: controller);
      case 1:
        return const _AnalysisContent();
      case 2:
        return const _ToolsContent();
      case 3:
        return const _PostExamContent();
      default:
        return _DashboardContent(controller: controller);
    }
  }
}

class _NavItem {
  const _NavItem({required this.label, required this.icon, this.iconAsset});
  final String label;
  final IconData icon;
  final String? iconAsset;
}

class _NavBarItem extends StatelessWidget {
  const _NavBarItem({
    required this.label,
    required this.icon,
    this.iconAsset,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String? iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.navBarActive : Colors.white.withValues(alpha: 0.75);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          margin: EdgeInsets.symmetric(horizontal: 4.w),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.navBarActive.withValues(alpha: 0.28) : Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
            border: isSelected ? Border.all(color: AppColors.navBarActive.withValues(alpha: 0.7), width: 1.2) : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconAsset != null)
                SizedBox(
                  width: 26.w,
                  height: 26.w,
                  child: Image.asset(
                    iconAsset!,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => Icon(icon, size: 24.sp, color: color),
                  ),
                )
              else
                Icon(icon, size: 24.sp, color: color),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 10.sp,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: color,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DashboardContent extends StatelessWidget {
  const _DashboardContent({required this.controller});
  final MainController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.dashboardLoading.value) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.dashboardError.value.isNotEmpty) {
        return Padding(
          padding: EdgeInsets.symmetric(vertical: 24.h),
          child: Center(
            child: Text(
              controller.dashboardError.value,
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
              textAlign: TextAlign.center,
            ),
          ),
        );
      }
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'At "NEETCounseling.com", we believe that the right guidance can turn your NEET UG score into a successful MBBS or BDS admission. Our platform offers comprehensive counselling support, college predictions, and expert advice to help you make informed choices.',
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
          SizedBox(height: 16.h),
          LayoutGrid(
            children: [
              MenuGridButton(
                label: 'News & Updates',
                iconAsset: '${MainView._icons}/news-update.png',
                onTap: () => Get.toNamed(AppRoutes.dashboardNews),
              ),
              MenuGridButton(
                label: 'Counselling Links',
                iconAsset: '${MainView._icons}/Counselling-Links.png',
                onTap: () => Get.toNamed(AppRoutes.dashboardCounsellingLinks),
              ),
              MenuGridButton(
                label: 'Colleges & Seats',
                iconAsset: '${MainView._icons}/collages.png',
                onTap: () => Get.toNamed(AppRoutes.analysisCollegeSeats),
              ),
              MenuGridButton(
                label: 'Webinars',
                iconAsset: '${MainView._icons}/webinar.png',
                onTap: () => Get.toNamed(AppRoutes.dashboardWebinars),
              ),
              MenuGridButton(
                label: 'Important Links',
                iconAsset: '${MainView._icons}/links.png',
                onTap: () => Get.toNamed(AppRoutes.dashboardImportantLinks),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _AnalysisContent extends StatelessWidget {
  const _AnalysisContent();

  @override
  Widget build(BuildContext context) {
    return LayoutGrid(
      children: [
        MenuGridButton(
          label: 'Past Years Competition',
          iconAsset: '${MainView._icons}/past_year.png',
          onTap: () => Get.toNamed(AppRoutes.analysisCompetitionStatistics),
        ),
        MenuGridButton(
          label: 'Seat Distribution',
          iconAsset: '${MainView._icons}/seat-distribution.png',
          onTap: () => Get.toNamed(AppRoutes.analysisSeatDistribution),
        ),
        MenuGridButton(
          label: 'Merit List',
          iconAsset: '${MainView._icons}/merit-list.png',
          onTap: () => Get.toNamed(AppRoutes.analysisMeritList),
        ),
        MenuGridButton(
          label: 'Courses',
          iconAsset: '${MainView._icons}/course.png',
          onTap: () => Get.toNamed(AppRoutes.analysisCourses),
        ),
      ],
    );
  }
}

class _ToolsContent extends StatelessWidget {
  const _ToolsContent();

  @override
  Widget build(BuildContext context) {
    return LayoutGrid(
      children: [
        MenuGridButton(
          label: 'Cut-Offs & Allotments',
          iconAsset: '${MainView._icons}/cut-off.png',
          onTap: () => Get.toNamed(AppRoutes.toolsCutoffAllotments),
        ),
        MenuGridButton(
          label: 'Fees & Seat Matrix',
          iconAsset: '${MainView._icons}/fee-seet.png',
          onTap: () => Get.toNamed(AppRoutes.toolsFeesSeatMatrix),
        ),
        MenuGridButton(
          label: 'College Ranking',
          iconAsset: '${MainView._icons}/collages.png',
          onTap: () => Get.toNamed(AppRoutes.toolsCollegeRanking),
        ),
        MenuGridButton(
          label: 'Counselling',
          iconAsset: '${MainView._icons}/Counselling.png',
          onTap: () => Get.toNamed(AppRoutes.toolsCounselling),
        ),
        MenuGridButton(
          label: 'Universities & Institutes',
          iconAsset: '${MainView._icons}/Universities&Institutes.png',
          onTap: () => Get.toNamed(AppRoutes.toolsUniversitiesInstitutes),
        ),
        // MenuGridButton(
        //   label: 'Documentation',
        //   iconAsset: '${MainView._icons}/Documentation.png',
        // ),
      ],
    );
  }
}

class _PostExamContent extends StatelessWidget {
  const _PostExamContent();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: MenuGridButton(
            label: 'SYCC Report',
            iconAsset: '${MainView._icons}/SYCC-Report.png',
            onTap: () => Get.toNamed(AppRoutes.syccReport),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: MenuGridButton(
            label: 'Checklist & Sample Views',
            iconAsset: '${MainView._icons}/Documentation.png',
            onTap: () => Get.toNamed(AppRoutes.postExamChecklistSample),
          ),
        ),
      ],
    );
  }
}

class LayoutGrid extends StatelessWidget {
  const LayoutGrid({super.key, required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    const int crossAxisCount = 2;
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i += crossAxisCount) {
      final rowChildren = children
          .skip(i)
          .take(crossAxisCount)
          .map((w) => Expanded(child: w))
          .toList();
      while (rowChildren.length < crossAxisCount) {
        rowChildren.add(const Expanded(child: SizedBox.shrink()));
      }
      rows.add(
        Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: Row(
            children: [
              rowChildren[0],
              SizedBox(width: 12.w),
              rowChildren[1],
            ],
          ),
        ),
      );
    }
    return Column(children: rows);
  }
}
