import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';

class AppTextStyles {
  const AppTextStyles._();

  static TextStyle get titleXL => TextStyle(
        fontSize: 30.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.2,
        color: AppColors.textDark,
      );

  static TextStyle get titleL => TextStyle(
        fontSize: 26.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.15,
        color: AppColors.textDark,
      );

  static TextStyle get titleM => TextStyle(
        fontSize: 22.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: 0.1,
        color: AppColors.textDark,
      );

  static TextStyle get bodyM => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        height: 1.4,
        color: AppColors.textMuted,
      );

  static TextStyle get bodyS => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 1.35,
        color: AppColors.textMuted,
      );

  static TextStyle get label => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textMuted,
      );

  static TextStyle get authHeading => TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.primaryBlue,
      );

  static TextStyle get authSubheading => TextStyle(
        fontSize: 11.5.sp,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: AppColors.textMuted,
      );

  static TextStyle get fieldHint => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 1.2,
        color: AppColors.hint,
      );

  static TextStyle get buttonText => TextStyle(
        fontSize: 13.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: Colors.white,
      );

  static TextStyle get mainScreenTitle => TextStyle(
        fontSize: 20.sp,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: AppColors.headerTitleOrange,
      );

  static TextStyle get welcomeHeading => TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: 0.1,
        color: AppColors.textDark,
      );

  static TextStyle get welcomeSubheading => TextStyle(
        fontSize: 12.sp,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: AppColors.textMuted,
      );

  static TextStyle get menuButtonLabel => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w600,
        height: 1.2,
        color: AppColors.textDark,
      );

  static TextStyle get detailScreenTitle => TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: AppColors.textDark,
      );

  static TextStyle get detailScreenSubtitle => TextStyle(
        fontSize: 11.sp,
        fontWeight: FontWeight.w500,
        height: 1.25,
        color: AppColors.textMuted,
      );
}
