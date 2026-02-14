import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'app_asset_image.dart';

class WelcomeCard extends StatelessWidget {
  const WelcomeCard({
    super.key,
    this.bookNowImageAsset,
    this.onBookNow,
  });

  final String? bookNowImageAsset;
  final VoidCallback? onBookNow;

  static const String _defaultCardImage = 'assets/images/splash-logo.png';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.chipBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Welcome Neet Counselling', style: AppTextStyles.welcomeHeading),
          SizedBox(height: 6.h),
          Text(
            'Begin the NEET Journey with your personalized Neet Counselling',
            style: AppTextStyles.welcomeSubheading,
          ),
          SizedBox(height: 14.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(14.r),
            child: SizedBox(
              height: 120.h,
              width: double.infinity,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFFF4D03F),
                      AppColors.brandGreen,
                    ],
                  ),
                ),
                child: Center(
                  child: AppAssetImage(
                    bookNowImageAsset ?? _defaultCardImage,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Schedule a counselling session with your Sr. Counselor :)',
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 12.h),
          Material(
            color: AppColors.bookNowBlue,
            borderRadius: BorderRadius.circular(12.r),
            elevation: 0,
            child: InkWell(
              onTap: onBookNow,
              borderRadius: BorderRadius.circular(12.r),
              child: Container(
                height: 48.h,
                alignment: Alignment.center,
                child: Text('Book Now', style: AppTextStyles.buttonText),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
