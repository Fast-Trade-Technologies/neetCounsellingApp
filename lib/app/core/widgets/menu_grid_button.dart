import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_asset_image.dart';

class MenuGridButton extends StatelessWidget {
  const MenuGridButton({
    super.key,
    required this.label,
    this.icon,
    this.iconAsset,
    this.onTap,
  }) : assert(
         icon != null || iconAsset != null,
         'Provide either icon or iconAsset',
       );

  final String label;
  final IconData? icon;
  final String? iconAsset;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = iconAsset != null
        ? AppAssetImage(
            iconAsset!,
            width: 32.w,
            height: 32.w,
            fit: BoxFit.contain,
          )
        : Icon(icon ?? Icons.circle, size: 28.sp, color: AppColors.primaryBlue);

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(40.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(40.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10.r,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              iconWidget,

              SizedBox(width: 10.w),

              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.menuButtonLabel.copyWith(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
