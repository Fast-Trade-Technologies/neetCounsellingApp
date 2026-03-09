import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/models/dashboard_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_app_bar.dart';
import '../../routes/app_routes.dart';

class WebinarsView extends StatelessWidget {
  const WebinarsView({super.key});

  static List<T> _listFromArguments<T>(dynamic arguments) {
    if (arguments == null) return [];
    if (arguments is List<T>) return arguments;
    if (arguments is List) return arguments.cast<T>();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final list = _listFromArguments<WebinarItem>(Get.arguments);
    final itemCount = list.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Webinars',
        subtitle: 'Neet Counselling / Dashboard',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Navigate back and refresh dashboard to reload webinars
          // Get.back();
          // try {
          //   final mainController = Get.find<MainController>();
          //   await mainController.loadDashboard();
          // } catch (e) {
          //   // MainController not found, skip refresh
          // }
        },
        color: AppColors.primaryBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: ClampingScrollPhysics(),
          ),
          slivers: [
            if (itemCount == 0)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'No webinars at the moment.',
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final item = list[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 14.h),
                      child: _WebinarCard(item: item),
                    );
                  }, childCount: itemCount),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}

class _WebinarCard extends StatelessWidget {
  const _WebinarCard({required this.item});
  final WebinarItem item;

  @override
  Widget build(BuildContext context) {
    final title = item.name ?? item.heading ?? 'Webinar';
    final desc = item.description ?? '';
    final date = item.dateFormatted ?? item.date ?? '';
    final time = item.time ?? '';
    final imageUrl = item.image;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    final body = desc.isEmpty
        ? (date.isNotEmpty || time.isNotEmpty
              ? 'Date: $date\nTime: $time'
              : 'Details will be updated soon.')
        : '${desc.replaceAll(RegExp(r'<[^>]*>'), '').trim()}\n\nDate: $date\nTime: $time';

    return GestureDetector(
      onTap: () {
        final webinarId = item.id;
        if (webinarId != null && webinarId.isNotEmpty) {
          // Navigate to webinar detail page with webinar data from list
          // Convert WebinarItem to Map for GetX navigation
          Get.toNamed(
            AppRoutes.webinarDetail,
            arguments: {
              'webinarId': webinarId,
              'webinarItem': {
                'id': item.id,
                'name': item.name,
                'heading': item.heading,
                'description': item.description,
                'date': item.date,
                'dateFormatted': item.dateFormatted,
                'time': item.time,
                'location': item.location,
                'courseTypeId': item.courseTypeId,
                'image': item.image,
              },
            },
          );
        } else {
          // Fallback to content detail if no ID
          Get.toNamed(
            AppRoutes.contentDetail,
            arguments: {'title': title, 'body': body, 'image': imageUrl},
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.chipBorder),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasImage) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: Image.network(
                  imageUrl,
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.fill,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    final expectedBytes = loadingProgress.expectedTotalBytes;
                    return Container(
                      width: double.infinity,
                      height: 180.h,
                      color: AppColors.chipBg,
                      child: Center(
                        child: CircularProgressIndicator(
                          value: expectedBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    expectedBytes
                              : null,
                          strokeWidth: 2,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 180.h,
                      color: AppColors.chipBg,
                      child: Icon(
                        Icons.image_not_supported,
                        size: 48.sp,
                        color: AppColors.textMuted,
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 12.h),
            ],
            Text(
              title,
              style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (desc.isNotEmpty) ...[
              SizedBox(height: 6.h),
              Text(
                desc.replaceAll(RegExp(r'<[^>]*>'), '').trim(),
                style: AppTextStyles.detailScreenSubtitle.copyWith(
                  color: AppColors.textDark,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            if (date.isNotEmpty || time.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 14.sp,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      date,
                      style: AppTextStyles.bodyS.copyWith(
                        fontSize: 11.sp,
                        color: AppColors.textMuted,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Icon(
                    Icons.access_time_rounded,
                    size: 14.sp,
                    color: AppColors.textMuted,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    time,
                    style: AppTextStyles.bodyS.copyWith(
                      fontSize: 11.sp,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
