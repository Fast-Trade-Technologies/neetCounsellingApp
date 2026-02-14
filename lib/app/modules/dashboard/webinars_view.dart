import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_app_bar.dart';
import '../../routes/app_routes.dart';

class WebinarsView extends StatelessWidget {
  const WebinarsView({super.key});

  static const List<Map<String, String>> _items = [
    {
      'title': "Attend India's Best NEET Counselling Webinar",
      'desc': 'Guidance on MBBS admissions with experts Dr. Prahaladha Singh, Sherly Rai, Sanjay Goyal.',
      'date': '20 April 2025',
      'time': '10:00:00',
    },
    {
      'title': 'Mistakes to Avoid During NEET Counseling & Choice Filling',
      'desc': 'Tips to avoid common mistakes during counseling and choice filling.',
      'date': '04 May 2025',
      'time': '10:00:00',
    },
    {
      'title': 'NEET Cutoff & College Predictor Masterclass',
      'desc': 'Breakdown of cutoffs and how to use college predictors effectively.',
      'date': '11 May 2025',
      'time': '10:00:00',
    },
    {
      'title': 'NEET Counseling Round-by-Round Strategy',
      'desc': 'Strategies for planning seat choices across different counseling rounds.',
      'date': '15 May 2025',
      'time': '10:00:00',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Webinars',
        subtitle: 'Neet Counselling / Dashboard',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ..._items.map((item) => _WebinarCard(
                  title: item['title']!,
                  desc: item['desc']!,
                  date: item['date']!,
                  time: item['time']!,
                )),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }
}

class _WebinarCard extends StatelessWidget {
  const _WebinarCard({
    required this.title,
    required this.desc,
    required this.date,
    required this.time,
  });

  final String title;
  final String desc;
  final String date;
  final String time;

  @override
  Widget build(BuildContext context) {
    final body = '$desc\n\nDate: $date\nTime: $time';
    return GestureDetector(
      onTap: () => Get.toNamed(
        AppRoutes.contentDetail,
        arguments: {'title': title, 'body': body},
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 14.h),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 6.h),
            Text(
              desc,
              style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(Icons.calendar_today_rounded, size: 14.sp, color: AppColors.textMuted),
                SizedBox(width: 4.w),
                Text(date, style: AppTextStyles.bodyS.copyWith(fontSize: 11.sp, color: AppColors.textMuted)),
                SizedBox(width: 12.w),
                Icon(Icons.access_time_rounded, size: 14.sp, color: AppColors.textMuted),
                SizedBox(width: 4.w),
                Text(time, style: AppTextStyles.bodyS.copyWith(fontSize: 11.sp, color: AppColors.textMuted)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
