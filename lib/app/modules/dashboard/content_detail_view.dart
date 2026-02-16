import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_app_bar.dart';

/// Generic detail page for news, links, etc. Pass [title] and [body] via arguments.
class ContentDetailView extends StatelessWidget {
  const ContentDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>? ?? {};
    final title = args['title'] as String? ?? 'Detail';
    final body = args['body'] as String? ?? '';

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
          child: Text(
          body.isEmpty
              ? 'Content will be displayed here. Expert support, personalized mentorship, and guidance for All India, State, Deemed, Management, and NRI quotas.'
              : body,
          style: AppTextStyles.bodyS.copyWith(
            color: AppColors.textDark,
            height: 1.5,
          ),
        ),
        ),
      ),
    );
  }
}
