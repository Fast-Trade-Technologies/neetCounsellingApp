import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Shows a bottom sheet with filter dropdowns and Submit.
/// [child] = row or column of dropdowns; Submit is added by this function.
void showFilterSheet({
  required BuildContext context,
  required Widget child,
  required VoidCallback onSubmit,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => Container(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h + MediaQuery.of(ctx).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48.w,
              height: 5.h,
              margin: EdgeInsets.only(top: 12.h),
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(3.r),
              ),
            ),
          ),
          SizedBox(height: 18.h),
          Text('Filters', style: AppTextStyles.welcomeHeading),
          SizedBox(height: 16.h),
          child,
          SizedBox(height: 18.h),
          SizedBox(
            height: 48.h,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onSubmit();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.navBarActive,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: Text('Submit', style: AppTextStyles.buttonText),
            ),
          ),
        ],
      ),
    ),
  );
}
