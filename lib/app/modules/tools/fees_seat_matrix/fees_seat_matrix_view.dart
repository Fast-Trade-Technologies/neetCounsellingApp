import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import 'fees_seat_matrix_controller.dart';

class FeesSeatMatrixView extends GetView<FeesSeatMatrixController> {
  const FeesSeatMatrixView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Fees & Seat Matrix',
        subtitle: 'Neet Counselling / Tools / Fees & Seat Matrix',
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
                'View seat distributions and corresponding fee structure offered by colleges for every category and subcategory.',
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

  Widget _buildFilterCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Obx(() => Text(controller.selectedState.value, style: AppTextStyles.welcomeHeading)),
          SizedBox(height: 4.h),
          Text(
            'Round-wise updates with the latest seat intakes of medical colleges',
            style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
          ),
          SizedBox(height: 14.h),
          Obx(() => Column(
            children: [
              Row(children: [Expanded(child: _FilterDropdown(label: 'State', value: controller.selectedState.value, items: controller.states, onChanged: controller.setState)), SizedBox(width: 10.w), Expanded(child: _FilterDropdown(label: 'Institute Type', value: controller.selectedInstituteType.value, items: FeesSeatMatrixController.instituteTypes, onChanged: controller.setInstituteType))]),
              SizedBox(height: 10.h),
              Row(children: [Expanded(child: _FilterDropdown(label: 'Quota', value: controller.selectedQuota.value, items: FeesSeatMatrixController.quotas, onChanged: controller.setQuota)), SizedBox(width: 10.w), Expanded(child: _FilterDropdown(label: 'Category', value: controller.selectedCategory.value, items: FeesSeatMatrixController.categories, onChanged: controller.setCategory))]),
              SizedBox(height: 10.h),
              Row(children: [Expanded(child: _FilterDropdown(label: 'Course', value: controller.selectedCourse.value, items: FeesSeatMatrixController.courses, onChanged: controller.setCourse)), SizedBox(width: 10.w), Expanded(child: _FilterDropdown(label: 'Year', value: controller.selectedYear.value, items: FeesSeatMatrixController.years, onChanged: controller.setYear))]),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
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
            final list = controller.filteredRows;
            if (list.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text('No results found.', style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted)),
              );
            }
            return Column(
              children: [
                for (int i = 0; i < list.length; i++) ...[
                  _FeesSeatCard(row: list[i]),
                  if (i < list.length - 1) SizedBox(height: 12.h),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }
}

class _FeesSeatCard extends StatelessWidget {
  const _FeesSeatCard({required this.row});

  final FeesSeatRow row;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.chipBg,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  '${row.sNo}',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.instituteAndType,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.sp,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _Chip(label: 'Course', value: row.course),
                        _Chip(label: 'Quota', value: row.quota),
                        _Chip(label: 'Category', value: row.category),
                        _Chip(label: 'Fees', value: row.fees),
                        _Chip(label: 'Seats', value: row.seats),
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
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(6.r),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: Text(
        '$label: $value',
        style: AppTextStyles.bodyS.copyWith(fontSize: 10.sp, color: AppColors.textDark),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  const _FilterDropdown({required this.label, required this.value, required this.items, required this.onChanged});

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final displayValue = items.contains(value) ? value : (items.isNotEmpty ? items.first : '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: AppTextStyles.detailScreenSubtitle.copyWith(fontSize: 10.sp, color: AppColors.textMuted),
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
              icon: Icon(Icons.keyboard_arrow_down_rounded, size: 18.sp, color: AppColors.textMuted),
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark, fontSize: 11.sp),
              items: items.map((e) => DropdownMenuItem<String>(value: e, child: Text(e, maxLines: 1, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: (v) => v != null ? onChanged(v) : null,
            ),
          ),
        ),
      ],
    );
  }
}
