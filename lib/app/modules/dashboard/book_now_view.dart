import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/url_launcher_util.dart' show launchPaymentPage, iosPurchaseDisclaimer;
import '../../core/widgets/detail_app_bar.dart';
import '../main/main_controller.dart';

class BookNowView extends StatelessWidget {
  const BookNowView({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isIOS = !kIsWeb && Platform.isIOS;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Book Now',
        subtitle: 'Schedule a counselling session',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Navigate back and refresh dashboard
          Get.back();
          try {
            final mainController = Get.find<MainController>();
            await mainController.loadDashboard();
          } catch (e) {
            // MainController not found, skip refresh
          }
        },
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Schedule a counselling session with your Sr. Counselor :)',
              style: AppTextStyles.welcomeHeading,
            ),
            SizedBox(height: 12.h),
            Text(
              'At NEETCounseling.com, we offer expert support, personalized mentorship, and have helped 24,000+ aspirants. Get guidance for All India, State, Deemed, Management, and NRI quotas.',
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
            SizedBox(height: 24.h),
            if (isIOS) ...[
              Text(
                iosPurchaseDisclaimer,
                style: AppTextStyles.bodyS.copyWith(
                  fontSize: 11.sp,
                  color: AppColors.textMuted,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ] else ...[
              Material(
                color: AppColors.bookNowBlue,
                borderRadius: BorderRadius.circular(12.r),
                child: InkWell(
                  onTap: () => launchPaymentPage(),
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    width: double.infinity,
                    height: 48.h,
                    alignment: Alignment.center,
                    child: Text('Book Now', style: AppTextStyles.buttonText),
                  ),
                ),
              ),
            ],
          ],
        ),
        ),
      ),
    );
  }
}
