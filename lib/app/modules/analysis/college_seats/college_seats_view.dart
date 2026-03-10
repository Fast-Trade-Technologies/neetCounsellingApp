import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import '../../../core/widgets/detail_dropdown.dart';
import '../../../core/widgets/filter_bottom_sheet.dart';
import 'college_seats_controller.dart';

class CollegeSeatsView extends GetView<CollegeSeatsController> {
  const CollegeSeatsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Analysis College &...',
        subtitle: 'College & Seats',
        onBack: () => Get.back(),
        onFilter: () => _openFilterSheet(context),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: _buildLayout(context),
        ),
      ),
    );
  }

  Widget _buildLayout(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 980;
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFD),
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(color: const Color(0xFFE6EDF5)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.06),
                blurRadius: 18,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 14.h),
              Container(
                height: 1,
                color: const Color(0xFFE8EEF6),
              ),
              SizedBox(height: 14.h),
              if (isWide)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 7, child: _buildMapPanel()),
                    SizedBox(width: 16.w),
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _buildSummaryCard(),
                          SizedBox(height: 14.h),
                          _buildCollegeCard(),
                        ],
                      ),
                    ),
                  ],
                )
              else ...[
                _buildMapPanel(),
                SizedBox(height: 14.h),
                _buildSummaryCard(),
                SizedBox(height: 14.h),
                _buildCollegeCard(),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('College & Seats', style: AppTextStyles.welcomeHeading.copyWith(fontSize: 24.sp)),
              SizedBox(height: 4.h),
              Text(
                'Navigate across different medical college seat distributions',
                style: AppTextStyles.bodyM.copyWith(color: const Color(0xFF47576B)),
              ),
            ],
          ),
        ),
        _buildStateDropdown(),
      ],
    );
  }

  Widget _buildStateDropdown() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0xFFD8E2EE)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'State',
            style: AppTextStyles.bodyM.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(0xFF142A52),
            ),
          ),
          SizedBox(width: 8.w),
          const Icon(Icons.keyboard_arrow_down_rounded, size: 20),
        ],
      ),
    );
  }

  Widget _buildMapPanel() {
    return Container(
      height: 520.h,
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 26.w, vertical: 18.h),
                child: InteractiveViewer(
                  transformationController: controller.mapTransformController,
                  minScale: 0.8,
                  maxScale: 4.0,
                  panEnabled: true,
                  child: SvgPicture.asset(
                    'assets/maps/india_states.svg',
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 10.w,
            top: 14.h,
            child: Column(
              children: [
                _buildMapAction(Icons.home_outlined, onTap: controller.resetMapView),
                SizedBox(height: 10.h),
                _buildMapAction(Icons.add, onTap: controller.zoomIn),
                SizedBox(height: 10.h),
                _buildMapAction(Icons.remove, onTap: controller.zoomOut),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapAction(IconData icon, {VoidCallback? onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Container(
        width: 36.w,
        height: 36.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10.r),
          border: Border.all(color: const Color(0xFFDCE5EF)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, size: 18, color: const Color(0xFF243A60)),
      ),
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Obx(
            () => Container(
              padding: EdgeInsets.all(4.w),
              decoration: BoxDecoration(
                color: const Color(0xFFE6EBF2),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SegmentTab(
                      label: 'Seat Wise',
                      isActive: controller.selectedTab.value == 0,
                      onTap: () => controller.setTab(0),
                    ),
                  ),
                  Expanded(
                    child: _SegmentTab(
                      label: 'College Wise',
                      isActive: controller.selectedTab.value == 1,
                      onTap: () => controller.setTab(1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Expanded(
                child: _buildMetricTile(value: '86854', label: 'Seats'),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _buildMetricTile(value: '739', label: 'Colleges'),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          _buildStatLine(title: 'Private (319)', value: '40,027'),
          SizedBox(height: 6.h),
          _buildProgress(0.47, const Color(0xFF0284C7)),
          SizedBox(height: 14.h),
          _buildStatLine(title: 'Government (420)', value: '46,352'),
          SizedBox(height: 6.h),
          _buildProgress(0.55, const Color(0xFF5DAD33)),
        ],
      ),
    );
  }

  Widget _buildMetricTile({required String value, required String label}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EDF4),
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: AppTextStyles.titleM.copyWith(
              fontSize: 28.sp,
              color: const Color(0xFF0D2345),
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: AppTextStyles.bodyM.copyWith(
              color: const Color(0xFF4A5D73),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatLine({required String title, required String value}) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.bodyM.copyWith(
              color: const Color(0xFF50627A),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Text(
          value,
          style: AppTextStyles.bodyM.copyWith(
            color: const Color(0xFF2C4567),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _buildProgress(double value, Color color) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6.r),
      child: LinearProgressIndicator(
        value: value,
        minHeight: 8.h,
        backgroundColor: const Color(0xFFDCE5EE),
        valueColor: AlwaysStoppedAnimation<Color>(color),
      ),
    );
  }

  Widget _buildCollegeCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F4F8),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: const Color(0xFFE8EDF4),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 34.w,
              height: 34.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(9.r),
              ),
              child: const Icon(Icons.account_balance_outlined, size: 20),
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          'ACSR GOVERNMENT MEDICAL\nCOLLEGE NELLORE',
                          style: AppTextStyles.detailScreenTitle.copyWith(
                            color: const Color(0xFF0B2350),
                            fontWeight: FontWeight.w800,
                            fontSize: 20.sp,
                          ),
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF3FA),
                          borderRadius: BorderRadius.circular(18.r),
                          border: Border.all(color: const Color(0xFFD1DEEE)),
                        ),
                        child: Text(
                          'Government',
                          style: AppTextStyles.bodyS.copyWith(
                            color: const Color(0xFF193A64),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Seats : 149',
                    style: AppTextStyles.bodyM.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF3C526D),
                    ),
                  ),
                  SizedBox(height: 10.h),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6F8FC),
                      borderRadius: BorderRadius.circular(16.r),
                      border: Border.all(color: const Color(0xFFD5DFEC)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.language_rounded, size: 14, color: Color(0xFF5C6D81)),
                        SizedBox(width: 6.w),
                        Text(
                          'Website',
                          style: AppTextStyles.bodyS.copyWith(
                            color: const Color(0xFF465A74),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showFilterSheet(
      context: context,
      onSubmit: () {},
      child: Row(
        children: [
          Expanded(child: DetailDropdown(label: 'All States')),
          SizedBox(width: 10.w),
          Expanded(child: DetailDropdown(label: 'Select Course')),
          SizedBox(width: 10.w),
          Expanded(child: DetailDropdown(label: '2015')),
        ],
      ),
    );
  }
}

class _SegmentTab extends StatelessWidget {
  const _SegmentTab({
    required this.label,
    required this.isActive,
    required this.onTap,
  });

  final String label;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFCFE1F3) : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: AppTextStyles.bodyM.copyWith(
            color: const Color(0xFF183760),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
