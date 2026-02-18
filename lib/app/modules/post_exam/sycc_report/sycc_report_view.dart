import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_asset_image.dart';
import '../../../core/widgets/detail_app_bar.dart';
import 'sycc_report_controller.dart';

class SyccReportView extends GetView<SyccReportController> {
  const SyccReportView({super.key});

  static const String _identifyIcon = 'assets/sycc-reports/identify.png';
  static const String _collegeIcon = 'assets/sycc-reports/college.png';
  static const String _reportIcon = 'assets/sycc-reports/report.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'SYCC Report',
        subtitle: 'Neet Counselling / Post-Exam / SYCC Report',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 24.h),
              _buildCard1(),
              SizedBox(height: 16.h),
              _buildCard2(),
              SizedBox(height: 16.h),
              _buildCard3(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'SYCC Report',
          style: AppTextStyles.titleXL.copyWith(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.w800,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          'Shortlist your counselling & colleges. Find the perfect institue with this activity to help understand your needs and narrow down your college options.',
          style: AppTextStyles.bodyM.copyWith(
            color: AppColors.textDark,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildCard1() {
    return _StepCard(
      iconAsset: _identifyIcon,
      title: 'Identify Your Requirements',
      description: 'Work with your Senior Mentor to outline your academic profile and goals :',
      backgroundColor: const Color(0xFFE3F2FD), // Light blue
      bullets: const [
        'Preferred Courses & Specializations',
        'Target Colleges & Locations',
        'NEET Marks / Expected Rank',
        'Quotas',
        'Counselling Bodies of Interest (AIQ, State, Deemed, etc.)',
      ],
    );
  }

  Widget _buildCard2() {
    return _StepCard(
      iconAsset: _collegeIcon,
      title: 'Shortlist Ideal Colleges',
      description: 'Explore a curated list of medical colleges based on:',
      backgroundColor: const Color(0xFFFFF9E6), // Light yellow
      bullets: const [
        'Your eligibility criteria',
        'Counselling formats (AIQ, State, Deemed, etc.)',
        'Institutional rankings & facilities',
        'Cutoff trends and success rates',
      ],
      additionalText: 'Your mentor will help you filter options to match both your academic standing and personal preferences.',
    );
  }

  Widget _buildCard3() {
    return _StepCard(
      iconAsset: _reportIcon,
      title: 'Generate Your Custom SYCC Report',
      description: 'Receive a personalized report directly in your inbox containing:',
      backgroundColor: const Color(0xFFE8F5E9), // Light green
      bullets: const [
        'Best-fit colleges',
        'Counselling types you are eligible for',
        'Expert insights based on your profile',
        'Statistics & guidance for each shortlisted option',
      ],
    );
  }
}

class _StepCard extends StatelessWidget {
  const _StepCard({
    required this.iconAsset,
    required this.title,
    required this.description,
    required this.backgroundColor,
    required this.bullets,
    this.additionalText,
  });

  final String iconAsset;
  final String title;
  final String description;
  final Color backgroundColor;
  final List<String> bullets;
  final String? additionalText;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: AppAssetImage(
              iconAsset,
              width: 80.w,
              height: 80.w,
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            title,
            style: AppTextStyles.titleM.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w800,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 12.h),
          Text(
            description,
            style: AppTextStyles.bodyM.copyWith(
              color: AppColors.textDark,
              height: 1.5,
            ),
          ),
          SizedBox(height: 16.h),
          ...bullets.map(
            (bullet) => Padding(
              padding: EdgeInsets.only(bottom: 10.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 8.h, right: 12.w),
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      bullet,
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (additionalText != null) ...[
            SizedBox(height: 12.h),
            Text(
              additionalText!,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
