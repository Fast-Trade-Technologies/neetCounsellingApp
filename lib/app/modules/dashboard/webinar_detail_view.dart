import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_app_bar.dart';
import 'webinar_detail_controller.dart';

class WebinarDetailView extends GetView<WebinarDetailController> {
  const WebinarDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chipBg,
      appBar: DetailAppBar(
        title: controller.heading.value.isNotEmpty 
            ? controller.heading.value 
            : 'Webinar Details',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primaryBlue,
        child: Obx(() {
          // Show loading only if we don't have any data yet
          if (controller.isLoading.value && controller.heading.value.isEmpty && controller.description.value.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: AppColors.primaryBlue),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading webinar details...',
                    style: AppTextStyles.bodyM.copyWith(color: AppColors.textMuted),
                  ),
                ],
              ),
            );
          }
          
          // Show refreshing indicator overlay if refreshing in background
          final isRefreshing = controller.isRefreshing.value;

          if (controller.error.value.isNotEmpty && controller.heading.value.isEmpty && controller.description.value.isEmpty) {
            return Center(
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.error_outline, size: 48.sp, color: Colors.red.shade700),
                    ),
                    SizedBox(height: 20.h),
                    Text(
                      'Oops!',
                      style: AppTextStyles.titleL.copyWith(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.red.shade700,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      controller.error.value,
                      style: AppTextStyles.bodyM.copyWith(color: AppColors.textDark),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton.icon(
                      onPressed: () => controller.refresh(),
                      icon: Icon(Icons.refresh_rounded, size: 20.sp),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryBlue,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Stack(
            children: [
              SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                // Hero Image Section
                if (controller.imageUrl.value.isNotEmpty) ...[
                  Container(
                    width: double.infinity,
                    height: 240.h,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.primaryBlue.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        ClipRRect(
                          child: Image.network(
                            controller.imageUrl.value,
                            width: double.infinity,
                            height: 240.h,
                            fit: BoxFit.fill,
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                width: double.infinity,
                                height: 240.h,
                                color: AppColors.chipBg,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                        : null,
                                    strokeWidth: 3,
                                    color: AppColors.primaryBlue,
                                  ),
                                ),
                              );
                            },
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: double.infinity,
                                height: 280.h,
                                color: AppColors.chipBg,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.image_not_supported, size: 64.sp, color: AppColors.textMuted),
                                    SizedBox(height: 8.h),
                                    Text(
                                      'Image not available',
                                      style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                        // Gradient overlay for better text readability
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withValues(alpha: 0.3),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Content Section
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Heading Card
                      if (controller.heading.value.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textDark.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.video_library_rounded,
                                  size: 24.sp,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Text(
                                  controller.heading.value,
                                  style: AppTextStyles.titleL.copyWith(
                                    fontSize: 20.sp,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textDark,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // Description Card
                      if (controller.description.value.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textDark.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.description_rounded,
                                    size: 20.sp,
                                    color: AppColors.primaryBlue,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'About This Webinar',
                                    style: AppTextStyles.titleM.copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16.h),
                              HtmlWidget(
                                controller.description.value,
                                textStyle: AppTextStyles.bodyM.copyWith(
                                  fontSize: 15.sp,
                                  color: AppColors.textDark,
                                  height: 1.7,
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 20.h),
                      ],

                      // Details Card
                      if (controller.dateFormatted.value.isNotEmpty || 
                          controller.time.value.isNotEmpty || 
                          controller.location.value.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20.w),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.textDark.withValues(alpha: 0.08),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.event_note_rounded,
                                    size: 20.sp,
                                    color: AppColors.primaryBlue,
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(
                                    'Event Details',
                                    style: AppTextStyles.titleM.copyWith(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primaryBlue,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20.h),
                              if (controller.dateFormatted.value.isNotEmpty) ...[
                                _buildDetailRow(
                                  icon: Icons.calendar_today_rounded,
                                  iconColor: AppColors.primaryBlue,
                                  label: 'Date',
                                  value: controller.dateFormatted.value,
                                ),
                                SizedBox(height: 16.h),
                              ],
                              if (controller.time.value.isNotEmpty) ...[
                                _buildDetailRow(
                                  icon: Icons.access_time_rounded,
                                  iconColor: AppColors.accentOrange,
                                  label: 'Time',
                                  value: controller.time.value,
                                ),
                                SizedBox(height: 16.h),
                              ],
                              if (controller.location.value.isNotEmpty) ...[
                                _buildDetailRow(
                                  icon: Icons.location_on_rounded,
                                  iconColor: AppColors.brandGreen,
                                  label: 'Location',
                                  value: controller.location.value,
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                      SizedBox(height: 24.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
              // Refreshing indicator overlay
              if (isRefreshing)
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.textDark.withValues(alpha: 0.2),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.chipBorder, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(icon, size: 22.sp, color: iconColor),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: AppTextStyles.bodyS.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  value,
                  style: AppTextStyles.bodyM.copyWith(
                    fontSize: 15.sp,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
