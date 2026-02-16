import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_app_bar.dart';
import '../../routes/app_routes.dart';

class NewsListView extends StatelessWidget {
  const NewsListView({super.key});

  static const List<Map<String, String>> _items = [
    {'title': 'MBBS Special Stray Round - Additional Allotment & Reporting Notice', 'body': 'Details about MBBS Special Stray Round additional allotment and reporting notice for NEET UG candidates.'},
    {'title': 'MBBS/BDS/BAMS/BHMS Round-05: Candidates Removed from Merit List Due to Non-Reporting (Security Deposit Forfeited)', 'body': 'Information on candidates removed from merit list and security deposit forfeiture in Round 5.'},
    {'title': 'ACPUGMEC Gujarat 2025-26: Final Admitted List for UG Medical Courses', 'body': 'Final admitted list for UG medical courses in Gujarat for the academic year 2025-26.'},
    {'title': 'NEET-UG 2025: Special Stray Round & Round 5 Counseling Schedule (MBBS/BDS/B.Sc Nursing)', 'body': 'Complete schedule for Special Stray Round and Round 5 counseling for MBBS, BDS, and B.Sc Nursing.'},
    {'title': 'UP NEET PG 2025: Important Guidelines for Third Round of Online Counselling', 'body': 'Guidelines for the third round of online counselling for NEET PG in Uttar Pradesh.'},
    {'title': 'Dr. NTRUHS AP: MBBS MQ 2025-26 Special Stray Round-2 Allotment List', 'body': 'Special Stray Round-2 allotment list for MBBS in Andhra Pradesh for 2025-26.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'News & Updates',
        subtitle: 'Neet Counselling / Dashboard',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Get timely alerts on all the NEET UG-related news and updates.',
              style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
            ),
            SizedBox(height: 16.h),
            ..._items.map((item) => _ListTile(
                  title: item['title']!,
                  body: item['body']!,
                )),
            SizedBox(height: 24.h),
          ],
        ),
        ),
      ),
    );
  }
}

class _ListTile extends StatelessWidget {
  const _ListTile({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.chipBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.article_outlined, size: 22.sp, color: AppColors.primaryBlue),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () => Get.toNamed(
                    AppRoutes.contentDetail,
                    arguments: {'title': title, 'body': body},
                  ),
                  child: Text(
                    'Check Now',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
