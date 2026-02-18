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
    this.trailing,
  });

  final String title;
  final String subtitle;
  final Color? titleColor;
  final VoidCallback? onBack;
  final VoidCallback? onFilter;
  final bool hideFilter;
  /// Optional widget shown at the end of the app bar (e.g. count badge).
  final Widget? trailing;

  @override
  Size get preferredSize => Size.fromHeight(72.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.fromLTRB(14.w, 10.h, 14.w, 12.h),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Material(
              color: AppColors.chipBg,
              elevation: 0,
              shadowColor: AppColors.textDark.withValues(alpha: 0.08),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: InkWell(
                onTap: onBack ?? () => Get.back(),
                borderRadius: BorderRadius.circular(12.r),
                child: SizedBox(
                  width: 48.w,
                  height: 48.w,
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    size: 20.sp,
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
            if (trailing != null) trailing!,
            if (!hideFilter)
              Material(
                color: AppColors.chipBg,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: InkWell(
                  onTap: onFilter,
                  borderRadius: BorderRadius.circular(12.r),
                  child: SizedBox(
                    width: 48.w,
                    height: 48.w,
                    child: Icon(
                      Icons.filter_list_rounded,
                      size: 22.sp,
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
