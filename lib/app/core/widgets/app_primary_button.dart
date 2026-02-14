import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.text,
    this.onTap,
    this.height,
    this.isDisabled = false,
  });

  final String text;
  final VoidCallback? onTap;
  final double? height;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isDisabled && onTap != null;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Opacity(
        opacity: enabled ? 1 : 0.6,
        child: Container(
          height: height ?? 44.h,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.r),
            gradient: const LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [AppColors.authButtonStart, AppColors.authButtonEnd],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.authButtonStart.withValues(alpha: 0.25),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Text(text, style: AppTextStyles.buttonText),
        ),
      ),
    );
  }
}

