import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import 'app_asset_image.dart';

class AuthBrandHeader extends StatelessWidget {
  const AuthBrandHeader({super.key, this.logoAsset});

  static const String _logoAsset = 'assets/images/splash-logo.png';

  /// When set (e.g. assets/auth/login-logo.png), shows this image as the full logo.
  final String? logoAsset;

  @override
  Widget build(BuildContext context) {
    if (logoAsset != null) {
      return Center(
        child: AppAssetImage(
          logoAsset!,
          height: 40.h,
          width: 200.w,
          fit: BoxFit.contain,
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AppAssetImage(_logoAsset, width: 34.w, height: 34.w),
        SizedBox(width: 8.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'NEET',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
        SizedBox(width: 6.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.brandGreen,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            'COUNSELLING',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.3,
            ),
          ),
        ),
      ],
    );
  }
}

