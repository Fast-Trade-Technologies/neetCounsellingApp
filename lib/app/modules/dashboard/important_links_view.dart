import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/models/dashboard_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/url_launcher_util.dart';
import '../../core/widgets/detail_app_bar.dart';
import '../../routes/app_routes.dart';

class ImportantLinksView extends StatelessWidget {
  const ImportantLinksView({super.key});

  static List<T> _listFromArguments<T>(dynamic arguments) {
    if (arguments == null) return [];
    if (arguments is List<T>) return arguments;
    if (arguments is List) return arguments.cast<T>();
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final list = _listFromArguments<ImportantLinkItem>(Get.arguments);
    final itemCount = list.length;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Important Links',
        subtitle: 'Neet Counselling / Dashboard',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        color: AppColors.primaryBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Optimize and boost your confidence with these essential resources.',
                    style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
                  ),
                  SizedBox(height: 16.h),
                ]),
              ),
            ),
            if (itemCount == 0)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                sliver: SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'No important links at the moment.',
                      style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                    ),
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final item = list[index];
                      return Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _ImportantLinkTile(item: item),
                      );
                    },
                    childCount: itemCount,
                  ),
                ),
              ),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}

class _ImportantLinkTile extends StatelessWidget {
  const _ImportantLinkTile({required this.item});
  final ImportantLinkItem item;

  @override
  Widget build(BuildContext context) {
    final title = item.heading ?? 'Important Link';
    final body = item.link?.trim().isNotEmpty == true
        ? 'Link: ${item.link}'
        : 'Link will be updated soon.';
    return Container(
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
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.article_outlined, size: 22.sp, color: AppColors.primaryBlue),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                InkWell(
                  onTap: () async {
                    if (item.link?.trim().isNotEmpty == true) {
                      await openLinkInBrowser(item.link);
                    } else {
                      Get.toNamed(
                        AppRoutes.contentDetail,
                        arguments: {'title': title, 'body': body},
                      );
                    }
                  },
                  child: Text(
                    'Check Now',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.primaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
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
