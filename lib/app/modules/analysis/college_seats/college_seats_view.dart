import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCard(context),
            SizedBox(height: 24.h),
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

  Widget _buildCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('College & Seats', style: AppTextStyles.welcomeHeading),
          SizedBox(height: 4.h),
          Text(
            'Here you can see different medical college and seat distributions',
            style: AppTextStyles.detailScreenSubtitle,
          ),
          SizedBox(height: 16.h),
          Container(
            height: 160.h,
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Center(
              child: Text(
                'Map of India',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.primaryBlue,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          SizedBox(height: 14.h),
          Obx(
            () => Row(
              children: [
                _TabChip(
                  label: 'Seat Wise',
                  isSelected: controller.selectedTab.value == 0,
                  onTap: () => controller.setTab(0),
                ),
                SizedBox(width: 16.w),
                _TabChip(
                  label: 'College Wise',
                  isSelected: controller.selectedTab.value == 1,
                  onTap: () => controller.setTab(1),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '86656',
                      style: AppTextStyles.titleM.copyWith(
                        fontSize: 18.sp,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text('Seats', style: AppTextStyles.detailScreenSubtitle),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '758',
                      style: AppTextStyles.titleM.copyWith(
                        fontSize: 18.sp,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text('Colleges', style: AppTextStyles.detailScreenSubtitle),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _ProgressRow(
            label: 'Private (310)',
            value: 0.4,
            color: AppColors.navBarActive,
            trailing: '45,000',
          ),
          SizedBox(height: 10.h),
          _ProgressRow(
            label: 'Government (448)',
            value: 0.6,
            color: AppColors.progressGreen,
            trailing: '46,000',
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              color: isSelected ? AppColors.textDark : AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Container(
            height: 3.h,
            width: 60.w,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.navBarActive : Colors.transparent,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressRow extends StatelessWidget {
  const _ProgressRow({
    required this.label,
    required this.value,
    required this.color,
    required this.trailing,
  });

  final String label;
  final double value;
  final Color color;
  final String trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4.r),
            child: LinearProgressIndicator(
              value: value,
              backgroundColor: AppColors.chipBg,
              valueColor: AlwaysStoppedAnimation<Color>(color),
              minHeight: 8.h,
            ),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          trailing,
          style: AppTextStyles.bodyS.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
