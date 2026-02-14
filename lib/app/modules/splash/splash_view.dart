import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.school_rounded, size: 80.sp, color: AppColors.primaryBlue),
            SizedBox(height: 16.h),
            Text('NEET Counselling', style: AppTextStyles.authHeading.copyWith(fontSize: 22.sp)),
            SizedBox(height: 32.h),
            SizedBox(
              width: 32.w,
              height: 32.w,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
            ),
          ],
        ),
      ),
    );
  }
}
