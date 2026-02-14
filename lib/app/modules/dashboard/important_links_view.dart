import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_app_bar.dart';
import '../../routes/app_routes.dart';

class ImportantLinksView extends StatelessWidget {
  const ImportantLinksView({super.key});

  static const List<Map<String, String>> _items = [
    {'title': 'Uttar Pradesh Private Colleges FEE 2025', 'body': 'Fee structure and details for Uttar Pradesh private medical colleges for 2025.'},
    {'title': 'Deemed Colleges FEE 2025', 'body': 'Fee structure and details for deemed medical colleges for 2025.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Important Links',
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
            Text(
              'Optimize and boost your confidence with these essential resources.',
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
                  maxLines: 2,
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
