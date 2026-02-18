import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import '../../../core/widgets/pagination_bar.dart';
import 'college_ranking_controller.dart';

class CollegeRankingView extends GetView<CollegeRankingController> {
  const CollegeRankingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'College Ranking',
        subtitle: 'Neet Counselling / Tools / College Ranking',
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
                'Best students deserve best institute. Examine the NC Ranking of medical college.',
                style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
              ),
              SizedBox(height: 16.h),
              _buildFilterCard(context),
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
    if (controller.clinicalTypeFilters.isEmpty) return const Expanded(child: SizedBox());
    return Expanded(
      child: _FilterDropdown(
        label: 'Clinical Type',
        value: controller.selectedClinicalType.value,
        items: controller.clinicalTypesForDropdown,
        onChanged: controller.setClinicalType,
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Obx(() {
        if (controller.filtersLoading.value) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: const Center(child: CircularProgressIndicator()),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('College Filter', style: AppTextStyles.welcomeHeading),
            SizedBox(height: 4.h),
            Text(
              'Approved intakes, & NC Rankings of your desired courses.',
              style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
            ),
            SizedBox(height: 14.h),
            Column(
              children: [
                Row(children: [Expanded(child: _FilterDropdown(label: 'State', value: controller.selectedState.value, items: controller.states, onChanged: controller.setState)), SizedBox(width: 10.w), Expanded(child: _FilterDropdown(label: 'Course', value: controller.selectedCourse.value, items: controller.coursesForDropdown, onChanged: controller.setCourse))]),
                SizedBox(height: 10.h),
                Row(children: [Expanded(child: _FilterDropdown(label: 'Institute Type', value: controller.selectedInstituteType.value, items: controller.instituteTypesForDropdown, onChanged: controller.setInstituteType)), SizedBox(width: 10.w), _buildClinicalTypeDropdown(context)]),
              ],
            ),
          ],
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
      if (controller.error.value.isNotEmpty && controller.filteredRows.isEmpty && controller.canLoad) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: _cardDecoration(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Showing Results', style: AppTextStyles.welcomeHeading),
              SizedBox(height: 16.h),
              Center(
                child: Text(
                  controller.error.value,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        );
      }
      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(16.w),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Showing Results', style: AppTextStyles.welcomeHeading),
            SizedBox(height: 12.h),
            TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search...',
                hintStyle: AppTextStyles.fieldHint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.border)),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10.r), borderSide: const BorderSide(color: AppColors.border)),
                contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
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
                  : (fromApi && total > 0 ? 'Showing $start–$end of $total' : 'Showing $start–$end');
              return PaginationBar(
                showingText: showingText,
                entriesPerPage: controller.entriesPerPage.value,
                entriesOptions: CollegeRankingController.entriesOptions,
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
                    controller.canLoad ? 'No results found.' : 'Select State to load data.',
                    style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              final perPage = controller.entriesPerPage.value;
              final startIndex = (controller.currentPage.value - 1) * perPage;
              return Column(
                children: [
                  for (int i = 0; i < list.length; i++) ...[
                    _CollegeRankingCard(row: list[i], serialNumber: startIndex + i + 1),
                    if (i < list.length - 1) SizedBox(height: 16.h),
                  ],
                ],
              );
            }),
          ],
        ),
      );
    });
  }
}

class _CollegeRankingCard extends StatelessWidget {
  const _CollegeRankingCard({required this.row, required this.serialNumber});

  final CollegeRankingRow row;
  final int serialNumber;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.chipBorder, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32.w,
                height: 32.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.2)),
                ),
                child: Text(
                  '$serialNumber',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.sp,
                  ),
                ),
              ),
              SizedBox(width: 14.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.instituteAndType,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                        fontSize: 13.sp,
                        height: 1.3,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 12.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 8.h,
                      children: [
                        _Chip(label: 'State', value: row.state),
                        _Chip(label: 'Degree(s)', value: row.degreesOffered),
                        _Chip(label: 'Est.', value: row.yearOfEstablishment),
                        _Chip(label: 'Seats', value: row.totalSeats),
                        _Chip(label: 'NC Rank', value: row.ncRanking),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.chipBorder, width: 1),
      ),
      child: RichText(
        text: TextSpan(
          style: AppTextStyles.bodyS.copyWith(fontSize: 11.sp, color: AppColors.textMuted),
          children: [
            TextSpan(text: '$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
            TextSpan(
              text: value,
              style: TextStyle(
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
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
    final displayValue =
        items.contains(value) ? value : (items.isNotEmpty ? items.first : '');
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
                  .map((e) => DropdownMenuItem<String>(
                        value: e,
                        child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis),
                      ))
                  .toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
            ),
          ),
        ),
      ],
    );
  }
}
