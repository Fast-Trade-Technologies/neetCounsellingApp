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
  }) : assert(icon != null || iconAsset != null,
            'Provide either icon or iconAsset');

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
        borderRadius: BorderRadius.circular(14.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: AppColors.chipBg,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: AppColors.chipBorder),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDark.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              iconWidget,
              SizedBox(height: 10.h),
              Text(
                label,
                style: AppTextStyles.menuButtonLabel,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
