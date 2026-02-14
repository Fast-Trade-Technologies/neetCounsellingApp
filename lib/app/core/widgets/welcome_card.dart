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
    return Card(
      elevation: 5,
      color: AppColors.background,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Welcome Neet Counselling', style: AppTextStyles.welcomeHeading),
            SizedBox(height: 4.h),
            Text(
              'Begin the NEET Journey with your personalized Neet Counselling',
              style: AppTextStyles.welcomeSubheading,
            ),
            SizedBox(height: 12.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: SizedBox(
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
                                // width: 70.w,
                                // height: 70.w,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
               ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Schedule a counselling session with your Sr. Counselor :)',
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 10.h),
            Material(
              color: AppColors.bookNowBlue,
              borderRadius: BorderRadius.circular(10.r),
              child: InkWell(
                onTap: onBookNow,
                borderRadius: BorderRadius.circular(10.r),
                child: Container(
                  height: 44.h,
                  alignment: Alignment.center,
                  child: Text('Book Now', style: AppTextStyles.buttonText),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
