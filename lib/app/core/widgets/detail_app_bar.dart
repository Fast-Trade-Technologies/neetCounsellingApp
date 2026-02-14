import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailAppBar({
    super.key,
    required this.title,
    this.subtitle = '',
    this.titleColor,
    this.onBack,
    this.onFilter,
    this.hideFilter = false,
  });

  final String title;
  final String subtitle;
  final Color? titleColor;
  final VoidCallback? onBack;
  final VoidCallback? onFilter;
  final bool hideFilter;

  @override
  Size get preferredSize => Size.fromHeight(72.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.background,
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 10.h),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Material(
              color: AppColors.chipBg,
              shape: const CircleBorder(),
              child: InkWell(
                onTap: onBack ?? () => Get.back(),
                customBorder: const CircleBorder(),
                child: Padding(
                  padding: EdgeInsets.all(10.w),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 18.sp,
                    color: AppColors.primaryBlue,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.detailScreenTitle.copyWith(
                      color: titleColor ?? AppColors.textDark,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty)
                    Text(
                      subtitle,
                      style: AppTextStyles.detailScreenSubtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            if (!hideFilter)
              Material(
                color: AppColors.chipBg,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: onFilter,
                  customBorder: const CircleBorder(),
                  child: Padding(
                    padding: EdgeInsets.all(10.w),
                    child: Icon(
                      Icons.filter_list_rounded,
                      size: 20.sp,
                      color: AppColors.primaryBlue,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
