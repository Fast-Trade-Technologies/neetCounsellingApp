import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_app_bar.dart';

/// Generic detail page for news, links, webinars, etc. Pass [title], [body], and optionally [image] via arguments.
class ContentDetailView extends StatelessWidget {
  const ContentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final title = args['title'] as String? ?? 'Detail';
    final body = args['body'] as String? ?? '';
    final imageUrl = args['image'] as String?;
    final hasImage = imageUrl != null && imageUrl.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: title,
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (hasImage) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    height: 250.h,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 250.h,
                        color: AppColors.chipBg,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
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
                        height: 250.h,
                        color: AppColors.chipBg,
                        child: Icon(Icons.image_not_supported, size: 48.sp, color: AppColors.textMuted),
                      );
                    },
                  ),
                ),
                SizedBox(height: 16.h),
              ],
              Text(
                body.isEmpty
                    ? 'Content will be displayed here. Expert support, personalized mentorship, and guidance for All India, State, Deemed, Management, and NRI quotas.'
                    : body,
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.textDark,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
