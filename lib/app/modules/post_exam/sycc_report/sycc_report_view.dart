import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import 'sycc_report_controller.dart';

class SyccReportView extends GetView<SyccReportController> {
  const SyccReportView({super.key});

  static const List<String> _bullets = [
    'Preferred Courses & Specializations',
    'Target Colleges & Locations',
    'NEET Marks / Expected Rank',
    'Quotas',
    'Counselling Bodies Of Interest (AIQ, State, Deemed, Etc.)',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'SYCC Report',
        titleColor: AppColors.primaryBlue,
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFirstCard(),
            SizedBox(height: 14.h),
            _buildSecondCard(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildFirstCard() {
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
          Text(
            'SYCC Report',
            style: AppTextStyles.welcomeHeading,
          ),
          SizedBox(height: 8.h),
          Text(
            'Shortlist your counseling & colleges. Find the perfect institue with this activity to help understand your needs and narrow down your college options.',
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.textDark,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecondCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: Column(
        children: [
          Icon(
            Icons.checklist_rounded,
            size: 56.sp,
            color: AppColors.accentOrange,
          ),
          SizedBox(height: 12.h),
          Text(
            'Identify Your Requirements',
            style: AppTextStyles.welcomeHeading.copyWith(
              color: AppColors.primaryBlue,
              fontSize: 15.sp,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'Work With Your Senior Mentor To Outline Your Academic Profile And Goals',
            style: AppTextStyles.detailScreenSubtitle,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ..._bullets.map(
            (e) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 6.h),
                    width: 6.w,
                    height: 6.w,
                    decoration: const BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Text(
                      e,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
