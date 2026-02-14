import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AuthOrDivider extends StatelessWidget {
  const AuthOrDivider({super.key, this.text = 'or continue with'});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.divider, thickness: 1.2)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 14.w),
            child: Text(text, style: AppTextStyles.bodyS),
          ),
          const Expanded(child: Divider(color: AppColors.divider, thickness: 1.2)),
        ],
      ),
    );
  }
}

