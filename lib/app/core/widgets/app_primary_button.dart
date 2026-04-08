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
    this.gradient,
    this.borderRadius,
    this.leading,
    this.textStyle,
  });

  final String text;
  final VoidCallback? onTap;
  final double? height;
  final bool isDisabled;
  final LinearGradient? gradient;
  final BorderRadius? borderRadius;
  final Widget? leading;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    final bool enabled = !isDisabled && onTap != null;
    final LinearGradient effectiveGradient = gradient ??
        const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [AppColors.authButtonStart, AppColors.authButtonEnd],
        );
    final BorderRadius effectiveBorderRadius =
        borderRadius ?? BorderRadius.circular(12.r);
    return Opacity(
      opacity: enabled ? 1 : 0.6,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: effectiveBorderRadius,
          child: Container(
            height: height ?? 48.h,
            width: double.infinity,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: effectiveBorderRadius,
              gradient: effectiveGradient,
              boxShadow: [
                BoxShadow(
                  color: effectiveGradient.colors.first.withValues(alpha: 0.2),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: leading == null
                ? Text(text, style: textStyle ?? AppTextStyles.buttonText)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      leading!,
                      SizedBox(width: 10.w),
                      Text(text, style: textStyle ?? AppTextStyles.buttonText),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

