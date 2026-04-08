import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neetcounsellingapp/app/routes/app_routes.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/app_asset_image.dart';
import 'onboarding_controller.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({super.key});

  static const _kPageCount = 4;

  // Replace these with your exact exported assets (png/svg).
  static const String _logoAsset = 'assets/images/splash-logo.png';
  static const String _p1Asset = 'assets/images/onboarding-1.png';
  static const String _p2Asset = 'assets/images/onboarding-2.png';
  static const String _p3Asset = 'assets/images/onboarding-3.jpeg';
  static const String _p4Asset = 'assets/images/onboarding-4.png';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // 🔹 Center Logo
              Center(
                child: AppAssetImage(
                  _logoAsset,
                  width: 54.w,
                  height: 54.w,
                ),
              ),

              // 🔹 Right Side Action Button
              Positioned(
                right: 0,
                child: Obx(
                  () => controller.pageIndex.value != 3 ? TextButton(
                    onPressed: () => Get.offAllNamed(AppRoutes.login),
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyM.copyWith(
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ) : InkWell(
                onTap: () {
                  Get.toNamed(AppRoutes.login);
                },
                child: Container(
                  height: 30.h,
                  width: 80.w,
                  margin: EdgeInsets.only(right: 10.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Center(
                    child: Text(
                      'Get Started',
                      style: AppTextStyles.label.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
                ),
              ),
            ],
          ),
            SizedBox(height: 6.h),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: const [
                  _OnboardingPage1(),
                  _OnboardingPage2(),
                  _OnboardingPage3(),
                  _OnboardingPage4(),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => controller.pageIndex.value < 3 ? InkWell(
                onTap: controller.goNextOrFinish,
                borderRadius: BorderRadius.circular(999),
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
                  child: _DotsIndicator(
                    count: _kPageCount,
                    index: controller.pageIndex.value,
                  ),
                ),
              ) : const SizedBox.shrink(),
            ),
            SizedBox(height: 14.h),
          ],
        ),
      ),
    );
  }
}

class _DotsIndicator extends StatelessWidget {
  const _DotsIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(count, (i) {
        final bool selected = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: 6.w),
          height: 8.h,
          width: selected ? 24.w : 8.w,
          decoration: BoxDecoration(
            color: selected ? AppColors.primaryBlue : AppColors.indicatorInactive,
            borderRadius: BorderRadius.circular(999),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: AppColors.primaryBlue.withValues(alpha: 0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
        );
      }),
    );
  }
}

class _OnboardingPage1 extends StatelessWidget {
  const _OnboardingPage1();

  @override
  Widget build(BuildContext context) {
    final double imageH =
        (MediaQuery.sizeOf(context).height * 0.42).clamp(180.0, 320.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 18.h),
            _RichTitle(
              top: 'Advanced Tools For',
              topColor: AppColors.accentOrange,
              bottom: 'NEET Counselling',
              bottomColor: AppColors.accentOrange,
              style: AppTextStyles.titleXL.copyWith(letterSpacing: 0.2),
            ),
            SizedBox(height: 6.h),
            Text(
              'MBBS and MD/MS',
              style: AppTextStyles.bodyS,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.h),
            AppAssetImage(
              OnboardingView._p1Asset,
              width: 320.w,
              height: imageH,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 18.h),
            Text(
              'NEET Rank Predictor\nColleges Ranking',
              style: AppTextStyles.titleM.copyWith(
                color: AppColors.primaryBlue,
                fontSize: 18.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              "India's NO.1 NEET Platform",
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.accentOrange,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage2 extends StatelessWidget {
  const _OnboardingPage2();

  @override
  Widget build(BuildContext context) {
    final double imageH =
        (MediaQuery.sizeOf(context).height * 0.43).clamp(180.0, 330.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 18.h),
            _RichTitle(
              top: 'Advanced Tools',
              topColor: AppColors.primaryBlue,
              bottom: 'for NEET Counselling',
              bottomColor: AppColors.deepBlue,
              style: AppTextStyles.titleXL.copyWith(letterSpacing: 0.2),
            ),
            SizedBox(height: 6.h),
            Text(
              'MBBS and MD/MS Admissions',
              style: AppTextStyles.bodyS,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'Stay Ahead of Competition',
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 18.h),
            AppAssetImage(
              OnboardingView._p2Asset,
              width: 330.w,
              height: imageH,
              fit: BoxFit.contain,
            ),
            SizedBox(height: 18.h),
            Text(
              'NEET Rank Predictor • College\nRankings',
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage3 extends StatelessWidget {
  const _OnboardingPage3();

  @override
  Widget build(BuildContext context) {
    final double imageH =
        (MediaQuery.sizeOf(context).height * 0.42).clamp(200.0, 340.0);
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 18.h),
            _RichTitle(
              top: 'Latest Resources',
              topColor: AppColors.primaryBlue,
              bottom: 'for NEET Counselling',
              bottomColor: AppColors.textDark,
              style: AppTextStyles.titleL.copyWith(letterSpacing: 0.2),
            ),
            SizedBox(height: 6.h),
            Text(
              'Cut-Offs • College Analysis • Alerts',
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.accentOrange,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              'Everything Under One Roof',
              style: AppTextStyles.bodyM.copyWith(
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            SizedBox(
              height: imageH,
              child: Center(
                child: AppAssetImage(
                  OnboardingView._p3Asset,
                  width: 320.w,
                  height: imageH,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _FeatureItem(
                    icon: Icons.bar_chart_rounded, label: 'Cut-Off\nStats'),
                _FeatureItem(
                    icon: Icons.school_rounded, label: 'College\nAnalysis'),
                _FeatureItem(
                    icon: Icons.notifications_active_rounded,
                    label: 'Counselling\nAlerts'),
                _FeatureItem(
                    icon: Icons.person_rounded, label: 'Personalised\nGuidance'),
              ],
            ),
            SizedBox(height: 10.h),
          ],
        ),
      ),
    );
  }
}

class _FeatureItem extends StatelessWidget {
  const _FeatureItem({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74.w,
      child: Column(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(10.r),
              border: Border.all(color: AppColors.chipBorder),
            ),
            child: Icon(icon, size: 20.sp, color: AppColors.primaryBlue),
          ),
          SizedBox(height: 6.h),
          Text(
            label,
            style: AppTextStyles.label.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _OnboardingPage4 extends StatelessWidget {
  const _OnboardingPage4();

  @override
  Widget build(BuildContext context) {
    final double imageH = 300.h;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          children: [
            SizedBox(height: 18.h),
            SizedBox(
              height: imageH,
              child: Center(
                child: AppAssetImage(
                  OnboardingView._p4Asset,
                  width: 340.w,
                  height: imageH,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            SizedBox(height: 10.h),
            _RichTitle(
              top: 'Your Ultimate Guide to',
              topColor: AppColors.accentOrange,
              bottom: 'NEET Counseling',
              bottomColor: AppColors.primaryBlue,
              style: AppTextStyles.titleL.copyWith(letterSpacing: 0.2),
            ),
            SizedBox(height: 8.h),
            Text(
              "Counselling dates, colleges, courses,\nfees, cut-offs, and beyond. Let’s take the\nguess work out of your choice filling.",
              style: AppTextStyles.bodyM,
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 12.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                _Chip(
                    icon: Icons.medical_services_rounded,
                    text: 'NEET UG & NEET PG'),
                _Chip(icon: Icons.badge_rounded, text: 'MBBS, MD/MS'),
                _Chip(
                    icon: Icons.local_hospital_rounded, text: 'BDS Admissions'),
              ],
            ),
            // SizedBox(height: 10.h),
            // Center(
            //   child: InkWell(
            //     onTap: () {
            //       Get.toNamed(AppRoutes.login);
            //     },
            //     child: Container(
            //       height: 48.h,
            //       width: 150.w,
            //       decoration: BoxDecoration(
            //         color: AppColors.primaryBlue,
            //         borderRadius: BorderRadius.circular(10.r),
            //       ),
            //       child: Center(
            //         child: Text(
            //           'Get Started',
            //           style: AppTextStyles.label.copyWith(
            //             color: Colors.white,
            //           ),
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 104.w,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20.sp, color: AppColors.primaryBlue),
          SizedBox(height: 6.h),
          Text(
            text,
            style: AppTextStyles.label.copyWith(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w700,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _RichTitle extends StatelessWidget {
  const _RichTitle({
    required this.top,
    required this.bottom,
    required this.topColor,
    required this.bottomColor,
    required this.style,
  });

  final String top;
  final String bottom;
  final Color topColor;
  final Color bottomColor;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: [
          TextSpan(text: top, style: style.copyWith(color: topColor)),
          const TextSpan(text: '\n'),
          TextSpan(text: bottom, style: style.copyWith(color: bottomColor)),
        ],
      ),
    );
  }
}

