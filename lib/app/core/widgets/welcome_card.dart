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

  static const String _defaultBannerImage =
      'assets/dashboard/dashboard-banner.png';

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Welcome Neet Counselling',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: AppColors.headerTitleOrange,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          'Begin the NEET Journey with your personalized Neet Counselling',
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
            height: 1.3,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 10.h),
    
        // Pills row
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _FeaturePill(label: 'Counselling Expert'),
                    SizedBox(width: 6.w),
                    _FeaturePill(label: 'All-round Support'),
                    SizedBox(width: 6.w),
                    _FeaturePill(label: 'Curated Strategies'),
                  ],
                ),
              ),
              
              SizedBox(height: 12.h),
              
              // Banner image (exact like screenshot)
              ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: SizedBox(
                  height: 160.h,
                  width: double.infinity,
                  child: AppAssetImage(
                    bookNowImageAsset ?? _defaultBannerImage,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              
              SizedBox(height: 12.h),
              
              // Short description
              Text(
                'Schedule a counselling session with your Sr. Counselor :)',
                style: AppTextStyles.welcomeHeading.copyWith(
                  fontSize: 14.sp,
                  color: const Color(0xFF0E4A7B),
                ),
              ),
              SizedBox(height: 8.h),
              
              // Long description (matches screenshot copy)
              Text(
                'At “NEETCounseling.com”, we believe that the right guidance can turn your NEET UG score into a successful MBBS or BDS admission. Since 2016, we have helped over 24,000 medical aspirants by offering expert support, personalized mentorship, and a smooth, stress-free counselling experience. Our dedicated team of 50+ senior counselors and medical admission experts works day and night to guide you through every step of the UG counselling process—be it All India, State, Deemed, Management or NRI quota.',
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.textDark,
                  height: 1.5,
                  fontSize: 11.5.sp,
                ),
              ),
              
              SizedBox(height: 16.h),
              
              // Book Now button (full-width, same style as screenshot)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  InkWell(
                    onTap: onBookNow,
                    borderRadius: BorderRadius.circular(10.r),
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                      decoration: BoxDecoration(
                        color: AppColors.bookNowBlue,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text('Book Now', style: AppTextStyles.buttonText),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _FeaturePill extends StatelessWidget {
  const _FeaturePill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3FF),
        borderRadius: BorderRadius.circular(10.r),
        // border: Border.all(color: const Color(0xFFB4D2FF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.check_circle_rounded,
            size: 14.sp,
            color: const Color(0xFF1E88E5),
          ),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E88E5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
