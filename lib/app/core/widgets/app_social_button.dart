import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import 'app_asset_image.dart';

class AppSocialButton extends StatelessWidget {
  const AppSocialButton({
    super.key,
    required this.label,
    this.icon,
    this.iconAsset,
    this.onTap,
  }) : assert(icon != null || iconAsset != null,
            'Provide either icon or iconAsset');

  final String label;
  final Widget? icon;
  final String? iconAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = iconAsset != null
        ? AppAssetImage(
            iconAsset!,
            width: 22.w,
            height: 22.w,
            fit: BoxFit.contain,
          )
        : (icon ?? const SizedBox.shrink());

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 44.h,
        width: 150.w,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 22.w, height: 22.w, child: Center(child: iconWidget)),
            SizedBox(width: 8.w),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

