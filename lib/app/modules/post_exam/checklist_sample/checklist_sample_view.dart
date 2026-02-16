import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import 'checklist_sample_controller.dart';

class ChecklistSampleView extends GetView<ChecklistSampleController> {
  const ChecklistSampleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Checklist & Sample Views',
        subtitle: 'Neet Counselling / Post-Exam / Checklist & Sample Views',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Look at the correct format for uploading the required documents for different counselling types. Ensure zero errors in your application!',
                style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
              ),
              SizedBox(height: 16.h),
              _buildFilterCard(context),
              SizedBox(height: 16.h),
              _buildSearchAndSections(context),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
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
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Obx(() => Row(
        children: [
          Text(
            'State',
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.textMuted,
              fontSize: 12.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: AppColors.border),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: controller.selectedState.value,
                  isExpanded: true,
                  isDense: true,
                  icon: Icon(Icons.keyboard_arrow_down_rounded, size: 20.sp, color: AppColors.textMuted),
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark, fontSize: 12.sp),
                  items: ChecklistSampleController.states
                      .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                      .toList(),
                  onChanged: (v) => v != null ? controller.setState(v) : null,
                ),
              ),
            ),
          ),
        ],
      )),
    );
  }

  Widget _buildSearchAndSections(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Documents', style: AppTextStyles.welcomeHeading),
          SizedBox(height: 12.h),
          TextField(
            onChanged: controller.setSearchQuery,
            decoration: InputDecoration(
              hintText: 'Search...',
              hintStyle: AppTextStyles.fieldHint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.r),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
              isDense: true,
            ),
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark),
          ),
          SizedBox(height: 16.h),
          _buildCollapsibleSection(
            title: 'GENERAL DOCUMENTS',
            count: controller.generalDocuments.length,
            isExpanded: controller.generalExpanded,
            onToggle: controller.toggleGeneral,
            documents: controller.generalDocuments,
          ),
          SizedBox(height: 10.h),
          _buildCollapsibleSection(
            title: 'SPECIAL CATEGORY',
            count: controller.specialCategoryDocuments.length,
            isExpanded: controller.specialExpanded,
            onToggle: controller.toggleSpecial,
            documents: controller.specialCategoryDocuments,
          ),
          SizedBox(height: 10.h),
          _buildCollapsibleSection(
            title: 'NRI DOCUMENTS',
            count: controller.nriDocuments.length,
            isExpanded: controller.nriExpanded,
            onToggle: controller.toggleNri,
            documents: controller.nriDocuments,
          ),
          SizedBox(height: 10.h),
          _buildCollapsibleSection(
            title: 'OCIPIO CANDIDATES DOCUMENTS',
            count: controller.ocipioDocuments.length,
            isExpanded: controller.ocipioExpanded,
            onToggle: controller.toggleOcipio,
            documents: controller.ocipioDocuments,
          ),
        ],
      ),
    );
  }

  Widget _buildCollapsibleSection({
    required String title,
    required int count,
    required RxBool isExpanded,
    required VoidCallback onToggle,
    required List<ChecklistDocument> documents,
  }) {
    return Obx(() {
      final expanded = isExpanded.value;
      final filtered = controller.filtered(documents);
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: AppColors.chipBorder),
        ),
        child: Column(
          children: [
            Material(
              color: AppColors.primaryBlue.withValues(alpha: 0.08),
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r), bottom: Radius.circular(expanded ? 0 : 12.r)),
              child: InkWell(
                onTap: onToggle,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12.r), bottom: Radius.circular(expanded ? 0 : 12.r)),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '$title ($count)',
                          style: AppTextStyles.bodyS.copyWith(
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                            fontSize: 13.sp,
                          ),
                        ),
                      ),
                      Icon(
                        expanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                        size: 24.sp,
                        color: AppColors.primaryBlue,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (expanded) ...[
              Padding(
                padding: EdgeInsets.all(12.w),
                child: filtered.isEmpty
                    ? Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                        child: Text(
                          'No documents match your search.',
                          style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                        ),
                      )
                    : Column(
                        children: [
                          for (int i = 0; i < filtered.length; i++) ...[
                            _DocumentCard(doc: filtered[i]),
                            if (i < filtered.length - 1) SizedBox(height: 10.h),
                          ],
                        ],
                      ),
              ),
            ],
          ],
        ),
      );
    });
  }
}

class _DocumentCard extends StatelessWidget {
  const _DocumentCard({required this.doc});

  final ChecklistDocument doc;

  void _onViewSample() {
    AppSnackbar.info('Sample View', 'Sample for "${doc.documentName}" will open when configured.');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: AppColors.chipBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 26.w,
            height: 26.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Text(
              '${doc.sNo}',
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.w700,
                fontSize: 11.sp,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              doc.documentName,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                fontSize: 12.sp,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          SizedBox(width: 10.w),
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: _onViewSample,
              borderRadius: BorderRadius.circular(8.r),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.visibility_rounded, size: 16.sp, color: AppColors.primaryBlue),
                    SizedBox(width: 6.w),
                    Text(
                      'View',
                      style: AppTextStyles.bodyS.copyWith(
                        fontSize: 11.sp,
                        color: AppColors.primaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
