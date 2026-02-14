import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import '../../../core/widgets/detail_dropdown.dart';
import '../../../core/widgets/filter_bottom_sheet.dart';
import 'cutoff_allotments_controller.dart';

class CutoffAllotmentsView extends GetView<CutoffAllotmentsController> {
  const CutoffAllotmentsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'TOOLS Cut-Off & A...',
        subtitle: 'Cut-Off & Allotments',
        onBack: () => Get.back(),
        onFilter: () => _openFilterSheet(context),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => _buildTopCard(controller.showResults.value)),
            SizedBox(height: 14.h),
            Obx(() => controller.showResults.value
                ? _buildResultsContent()
                : SizedBox(height: 60.h)),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showFilterSheet(
      context: context,
      onSubmit: controller.submit,
      child: Column(
        children: [
          DetailDropdown(label: 'All States'),
          SizedBox(height: 10.h),
          DetailDropdown(label: 'Select Institute Type'),
          SizedBox(height: 10.h),
          DetailDropdown(label: 'Select Course'),
        ],
      ),
    );
  }

  Widget _buildTopCard(bool isResults) {
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
          Text('Uttar Pradesh', style: AppTextStyles.welcomeHeading),
          SizedBox(height: 4.h),
          Text(
            isResults
                ? 'Shortlisted colleges for cut-off and allotment of medical colleges'
                : 'Select what you want to show the Cut-Off & Allotment of medical colleges',
            style: AppTextStyles.detailScreenSubtitle,
          ),
        ],
      ),
    );
  }

  Widget _buildResultsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Showing Results',
          style: AppTextStyles.welcomeHeading,
        ),
        SizedBox(height: 12.h),
        _InstituteCard(
          name: 'SRI RAM MURTI SMARAK INSTITUTE OF MEDICAL SCIENCES, BAREILLY',
          course: 'MBBS',
          quota: 'General',
          mOpen: '1724',
          mClos: '18210',
          category: 'N/A',
          pwd: 'N/A',
          scOpen: '94900',
          scClos: 'N/A',
        ),
        SizedBox(height: 10.h),
        _InstituteCard(
          name: 'SRI RAM MURTI SMARAK INSTITUTE OF MEDICAL SCIENCES, BAREILLY',
          course: 'MBBS',
          quota: 'General',
          mOpen: '1724',
          mClos: '18210',
          category: 'N/A',
          pwd: 'N/A',
          scOpen: '94900',
          scClos: 'N/A',
        ),
        SizedBox(height: 10.h),
        _InstituteCard(
          name: 'SRI RAM MURTI SMARAK INSTITUTE OF MEDICAL SCIENCES, BAREILLY',
          course: 'MBBS',
          quota: 'General',
          mOpen: '1724',
          mClos: '18210',
          category: 'N/A',
          pwd: 'N/A',
          scOpen: '94900',
          scClos: 'N/A',
        ),
      ],
    );
  }
}

class _InstituteCard extends StatelessWidget {
  const _InstituteCard({
    required this.name,
    required this.course,
    required this.quota,
    required this.mOpen,
    required this.mClos,
    required this.category,
    required this.pwd,
    required this.scOpen,
    required this.scClos,
  });

  final String name;
  final String course;
  final String quota;
  final String mOpen;
  final String mClos;
  final String category;
  final String pwd;
  final String scOpen;
  final String scClos;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            name,
            style: AppTextStyles.bodyS.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
              fontSize: 11.sp,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Course:', course),
                    _kv('Quota:', quota),
                    _kv('M.OPEN:', mOpen),
                    _kv('M.CLOS:', mClos),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _kv('Category:', category),
                    _kv('Pwd:', pwd),
                    _kv('SC.OPEN:', scOpen),
                    _kv('SC.CLOS:', scClos),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _kv(String k, String v) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.detailScreenSubtitle.copyWith(
            color: AppColors.textDark,
            fontSize: 10.sp,
          ),
          children: [
            TextSpan(text: '$k '),
            TextSpan(
              text: v,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
