import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';
import 'package:neetcounsellingapp/app/core/widgets/pagination_bar.dart';
import 'package:neetcounsellingapp/app/core/widgets/plan_locked_section.dart';
import 'package:neetcounsellingapp/app/modules/tools/cutoff_allotments/cutoff_allotments_controller.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import '../../../core/widgets/filter_bottom_sheet.dart';

class CutoffAllotmentsView extends GetView<CutoffAllotmentsController> {
  const CutoffAllotmentsView({super.key});

  // Plan value: show full data only when user has active/paid plan
  bool get isActivePlan => AppStorage.hasActivePlan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Cut Off Allotments',
        subtitle: 'Neet Counselling / Tools / Cut Off Allotments',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeaderCard(context),
              SizedBox(height: 16.h),
              _buildResultsSection(context),
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

  Widget _buildClinicalTypeDropdown(BuildContext context) {
    if (controller.clinicalTypeFilters.isEmpty) {
      return const Expanded(child: SizedBox());
    }
    return Expanded(
      child: _FilterDropdown(
        label: 'Clinical Type',
        value: controller.selectedClinicalType.value,
        items: controller.clinicalTypesForDropdown,
        onChanged: controller.setClinicalType,
      ),
    );
  }

  /// Header card (same style as seat distribution / college seats). >3 filters → only in sheet.
  Widget _buildHeaderCard(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        color: Colors.white,
        elevation: 5,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30.r),
          side: BorderSide(color: AppColors.border),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.w, vertical: 10.h),
          child: Obx(() {
            final title = controller.selectedState.value.isEmpty
                ? 'Cut Off Allotments'
                : controller.selectedState.value;
            return Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Round-wise updates with the latest closing ranks and allotments details of medical colleges',
                        style: AppTextStyles.bodyM.copyWith(
                          color: const Color(0xFF47576B),
                          fontSize: 10.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () => _openFilterSheet(context),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(8.w),
                      child: Icon(
                        Icons.filter_list_rounded,
                        size: 24.sp,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _openFilterSheet(BuildContext context) {
    showFilterSheet(
      context: context,
      onSubmit: () => controller.refresh(),
      child: Obx(() {
        if (controller.filtersLoading.value) {
          return const Padding(
            padding: EdgeInsets.all(24.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      label: 'State',
                      value: controller.selectedState.value,
                      items: controller.states,
                      onChanged: controller.setState,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Year',
                      value: controller.selectedYear.value,
                      items: controller.yearsForDropdown,
                      onChanged: controller.setYear,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Counselling Type',
                      value: controller.selectedCounsellingType.value,
                      items: controller.counsellingTypesForDropdown,
                      onChanged: controller.setCounsellingType,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Institute Type',
                      value: controller.selectedInstituteType.value,
                      items: controller.instituteTypesForDropdown,
                      onChanged: controller.setInstituteType,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Course',
                      value: controller.selectedCourse.value,
                      items: controller.coursesForDropdown,
                      onChanged: controller.setCourse,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Quota',
                      value: controller.selectedQuota.value,
                      items: controller.quotasForDropdown,
                      onChanged: controller.setQuota,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Category',
                      value: controller.selectedCategory.value,
                      items: controller.categoriesForDropdown,
                      onChanged: controller.setCategory,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  _buildClinicalTypeDropdown(context),
                  SizedBox(width: 10.w),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value && controller.filteredRows.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
          decoration: _cardDecoration(),
          child: const Center(child: CircularProgressIndicator()),
        );
      }
      if (controller.error.value.isNotEmpty &&
          controller.filteredRows.isEmpty &&
          controller.canLoad) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Showing Results',
                style: AppTextStyles.welcomeHeading.copyWith(
                  color: AppColors.primaryBlue,
                  fontSize: 16.sp,
                ),
              ),
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  controller.error.value,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }
      return SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Showing Results',
              style: AppTextStyles.welcomeHeading.copyWith(
                color: AppColors.primaryBlue,
                fontSize: 16.sp,
              ),
            ),
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
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 12.w,
                  vertical: 10.h,
                ),
                isDense: true,
              ),
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark),
            ),
            SizedBox(height: 12.h),
            Obx(() {
              final total = controller.totalCount.value;
              final fromApi = controller.totalCountFromApi.value;
              final start = controller.paginationStart;
              final end = controller.paginationEnd;
              final showingText = controller.filteredRows.isEmpty
                  ? 'Showing 0–0 of 0'
                  : (fromApi && total > 0
                        ? 'Showing $start–$end of $total'
                        : 'Showing $start–$end');
              return PaginationBar(
                showingText: showingText,
                entriesPerPage: controller.entriesPerPage.value,
                entriesOptions: CutoffAllotmentsController.entriesOptions,
                onEntriesPerPageChanged: controller.setEntriesPerPage,
                hasPreviousPage: controller.hasPreviousPage,
                hasNextPage: controller.hasNextPage,
                onPreviousPage: controller.previousPage,
                onNextPage: controller.nextPage,
                currentPage: controller.currentPage.value,
                totalPages: controller.totalPages,
                onPageTap: controller.goToPage,
              );
            }),
            SizedBox(height: 12.h),
            Obx(() {
              final list = controller.filteredRows;
              if (list.isEmpty) {
                return Padding(
                  padding: EdgeInsets.symmetric(vertical: 24.h),
                  child: Text(
                    controller.canLoad
                        ? 'No results found.'
                        : 'Select State and Year to load data.',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final year = controller.selectedYear.value;
              return PlanLockedSection(
                isActivePlan: isActivePlan,
                itemCount: list.length,
                unlockedCount: 4,
                itemSpacing: 16.h,
                itemBuilder: (context, i) =>
                    _CutoffCard(row: list[i], year: year),
              );
            }),
          ],
        ),
      );
    });
  }

}

class _CutoffCard extends StatelessWidget {
  const _CutoffCard({required this.row, required this.year});

  final CutoffRow row;
  final String year;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFD),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE6EDF5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            row.instituteAndType,
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.textDark,
              fontWeight: FontWeight.w700,
              fontSize: 14.sp,
              height: 1.3,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 10.h),
          Container(
            height: 2,
            width: double.infinity,
            color: AppColors.primaryBlue,
          ),
          SizedBox(height: 14.h),
          _DetailRow(
            leftLabel: 'Course:',
            leftValue: row.course,
            rightLabel: 'Category:',
            rightValue: row.category.isEmpty ? 'N/A' : row.category,
          ),
          SizedBox(height: 10.h),
          _DetailRow(
            leftLabel: 'Quota:',
            leftValue: row.quota,
            rightLabel: 'Fees:',
            rightValue: row.fees,
          ),
          SizedBox(height: 10.h),
          _DetailRow(
            leftLabel: 'R1 ($year)',
            leftValue: row.r1,
            rightLabel: 'R2 ($year)',
            rightValue: row.r2,
          ),
          SizedBox(height: 10.h),
          _DetailRow(
            leftLabel: 'R3 ($year)',
            leftValue: row.r3,
            rightLabel: 'R4 ($year)',
            rightValue: row.r4,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.leftLabel,
    required this.leftValue,
    required this.rightLabel,
    required this.rightValue,
  });

  final String leftLabel;
  final String leftValue;
  final String rightLabel;
  final String rightValue;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: _KeyValue(label: leftLabel, value: leftValue),
        ),
        SizedBox(width: 16.w),
        Expanded(
          child: _KeyValue(label: rightLabel, value: rightValue),
        ),
      ],
    );
  }
}

class _KeyValue extends StatelessWidget {
  const _KeyValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: AppTextStyles.bodyS.copyWith(
          fontSize: 12.sp,
          color: AppColors.textDark,
          height: 1.4,
        ),
        children: [
          TextSpan(
            text: '$label ',
            style: TextStyle(
              fontWeight: FontWeight.w500,
              color: AppColors.textMuted,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final displayValue = items.contains(value)
        ? value
        : (items.isNotEmpty ? items.first : '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.detailScreenSubtitle.copyWith(
            fontSize: 10.sp,
            color: AppColors.textMuted,
          ),
        ),
        SizedBox(height: 4.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: displayValue,
              isExpanded: true,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18.sp,
                color: AppColors.textMuted,
              ),
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                fontSize: 11.sp,
              ),
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
            ),
          ),
        ),
      ],
    );
  }
}
