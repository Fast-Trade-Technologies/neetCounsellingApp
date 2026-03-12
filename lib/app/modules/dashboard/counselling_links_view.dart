import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../core/models/dashboard_models.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/url_launcher_util.dart';
import '../../core/widgets/detail_app_bar.dart';
import '../../core/widgets/detail_dropdown.dart';
import '../../routes/app_routes.dart';
import 'counselling_links_controller.dart';

class CounsellingLinksView extends GetView<CounsellingLinksController> {
  const CounsellingLinksView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Counselling Links',
        subtitle: 'Neet Counselling / Dashboard',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.loadData(),
        color: AppColors.primaryBlue,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
          cacheExtent: 200,
          slivers: [
            SliverPadding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  Text(
                    'Important NEET UG Counselling Links.',
                    style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
                  ),
                  SizedBox(height: 12.h),
                  _StateDropdown(controller: controller),
                  SizedBox(height: 16.h),
                ]),
              ),
            ),
            Obx(() {
              if (controller.loading.value) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  sliver: const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              if (controller.error.value.isNotEmpty) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        controller.error.value,
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                );
              }
              final itemCount = controller.list.length;
              if (itemCount == 0) {
                return SliverPadding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
                  sliver: SliverToBoxAdapter(
                    child: Center(
                      child: Text(
                        'No counselling links at the moment.',
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                      ),
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => RepaintBoundary(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _LinkTile(item: controller.list[index]),
                      ),
                    ),
                    childCount: itemCount,
                  ),
                ),
              );
            }),
            SliverToBoxAdapter(child: SizedBox(height: 24.h)),
          ],
        ),
      ),
    );
  }
}

class _StateDropdown extends StatelessWidget {
  const _StateDropdown({required this.controller});
  final CounsellingLinksController controller;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showStatePicker(context),
      borderRadius: BorderRadius.circular(12.r),
      child: Obx(() => DetailDropdown(
            label: 'State',
            value: controller.selectedStateName.value.isEmpty
                ? null
                : controller.selectedStateName.value,
            items: null,
          )),
    );
  }

  void _showStatePicker(BuildContext context) {
    final states = controller.stateFilters;
    final scrollController = ScrollController();
    final maxHeight = MediaQuery.of(context).size.height * 0.5;
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text('Select State', style: AppTextStyles.welcomeHeading),
              ),
              SizedBox(
                height: maxHeight,
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: ListView(
                    controller: scrollController,
                    shrinkWrap: true,
                    children: [
                      ListTile(
                        title: Text('All States', style: AppTextStyles.bodyS),
                        onTap: () {
                          controller.setStateFilter(null);
                          Navigator.pop(ctx);
                        },
                      ),
                      ...states.map((e) => ListTile(
                            title: Text(e.name, style: AppTextStyles.bodyS),
                            onTap: () {
                              controller.setStateFilter(e);
                              Navigator.pop(ctx);
                            },
                          )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  const _LinkTile({required this.item});
  final CounsellingLinkItem item;

  @override
  Widget build(BuildContext context) {
    final title = item.heading ?? 'Counselling Link';
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
          Icon(Icons.link_rounded, size: 22.sp, color: AppColors.primaryBlue),
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
