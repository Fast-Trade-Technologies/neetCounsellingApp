import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import 'merit_list_controller.dart';

class MeritListView extends GetView<MeritListController> {
  const MeritListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Merit List',
        subtitle: 'Evaluating merits lists containing data about applied and participating candidates in state-wise counselling rounds.',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFilterCard(context),
            SizedBox(height: 20.h),
            _buildEligibleCandidatesSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
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
          Obx(() => Text(
                controller.selectedState.value,
                style: AppTextStyles.welcomeHeading,
              )),
          SizedBox(height: 6.h),
          Text(
            'Select a year to view the Merit List analysis in Uttar Pradesh',
            style: AppTextStyles.detailScreenSubtitle.copyWith(
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 14.h),
          Obx(() => Column(
            children: [
              _SelectTile(
                label: 'Counselling Type',
                value: controller.selectedCounsellingType.value,
                onTap: () => _showStringSheet(
                  context,
                  'Select Counselling Type',
                  controller.counsellingTypes,
                  controller.selectedCounsellingType.value,
                  controller.setCounsellingType,
                ),
              ),
              SizedBox(height: 10.h),
              _SelectTile(
                label: 'State',
                value: controller.selectedState.value,
                onTap: () => _showStringSheet(
                  context,
                  'Select State',
                  controller.states,
                  controller.selectedState.value,
                  controller.setState,
                ),
              ),
              SizedBox(height: 10.h),
              _SelectTile(
                label: 'Year',
                value: controller.selectedYear.value,
                onTap: () => _showStringSheet(
                  context,
                  'Select Year',
                  controller.years,
                  controller.selectedYear.value,
                  controller.setYear,
                ),
              ),
            ],
          )),
        ],
      ),
    );
  }

  Widget _buildEligibleCandidatesSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Eligible Candidates', style: AppTextStyles.welcomeHeading),
        SizedBox(height: 12.h),
        Row(
          children: [
            Obx(() => _EntriesPerPageDropdown(
              label: 'Entries per page',
              value: controller.entriesPerPage.value,
              options: controller.entriesOptions,
              onChanged: controller.setEntriesPerPage,
            )),
            SizedBox(width: 12.w),
            Expanded(child: _SearchField(controller: controller)),
          ],
        ),
        SizedBox(height: 12.h),
        _buildMeritList(),
      ],
    );
  }

  Widget _buildMeritList() {
    return Obx(() {
      final list = controller.filteredEntries;
      if (list.isEmpty) {
        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(24.w),
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
          child: Text(
            'No merit lists found.',
            style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
          ),
        );
      }
      return Column(
        children: [
          for (int i = 0; i < list.length; i++) ...[
            _MeritListCard(
              entry: list[i],
              onCheckNow: () => controller.onCheckNow(list[i]),
            ),
            if (i < list.length - 1) SizedBox(height: 12.h),
          ],
        ],
      );
    });
  }

  void _showStringSheet(
    BuildContext context,
    String title,
    List<String> items,
    String currentValue,
    ValueChanged<String> onSelected,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
          boxShadow: [
            BoxShadow(
              color: AppColors.textDark.withValues(alpha: 0.12),
              blurRadius: 16,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h + MediaQuery.of(ctx).padding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: AppColors.border,
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Text(title, style: AppTextStyles.welcomeHeading),
            SizedBox(height: 12.h),
            ...List.generate(items.length, (i) {
              final e = items[i];
              return Padding(
                padding: EdgeInsets.only(bottom: i < items.length - 1 ? 8.h : 0),
                child: _SheetOptionTile(
                  label: e,
                  isSelected: e == currentValue,
                  onTap: () {
                    Navigator.of(ctx).pop();
                    onSelected(e);
                  },
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

}

class _EntriesPerPageDropdown extends StatelessWidget {
  const _EntriesPerPageDropdown({
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final int value;
  final List<int> options;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80.w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Text(
          //   label,
          //   style: AppTextStyles.detailScreenSubtitle.copyWith(
          //     fontSize: 11.sp,
          //     color: AppColors.textMuted,
          //   ),
          // ),
          // SizedBox(height: 6.h),
          Container(
            height: 40.h,
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.textDark.withValues(alpha: 0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: value,
                isExpanded: true,
                isDense: false,
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 22.sp,
                  color: AppColors.primaryBlue,
                ),
                dropdownColor: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                elevation: 8,
                style: AppTextStyles.bodyS.copyWith(
                  color: AppColors.textDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 13.sp,
                ),
                items: options
                    .map((e) => DropdownMenuItem<int>(
                          value: e,
                          child: Text(
                            '$e',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ))
                    .toList(),
                onChanged: (v) => v != null ? onChanged(v) : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectTile extends StatelessWidget {
  const _SelectTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
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
              Expanded(
                child: Column(
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
                    SizedBox(height: 2.h),
                    Text(
                      value,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 13.sp,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 24.sp,
                color: AppColors.textMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetOptionTile extends StatelessWidget {
  const _SheetOptionTile({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.chipBg : Colors.white,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textDark,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_rounded,
                  size: 22.sp,
                  color: AppColors.primaryBlue,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeritListCard extends StatelessWidget {
  const _MeritListCard({
    required this.entry,
    required this.onCheckNow,
  });

  final MeritListEntry entry;
  final VoidCallback onCheckNow;

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
                  '${entry.sNo}',
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
                      entry.pdfName,
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 4.h,
                      children: [
                        _ChipLabel(label: entry.state),
                        _ChipLabel(label: entry.year),
                        _ChipLabel(label: entry.counsellingType),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    _CheckNowButton(onTap: onCheckNow),
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

class _ChipLabel extends StatelessWidget {
  const _ChipLabel({required this.label});

  final String label;

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
        label,
        style: AppTextStyles.bodyS.copyWith(
          fontSize: 11.sp,
          color: AppColors.textDark,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField({required this.controller});

  final MeritListController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
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
        contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        isDense: true,
      ),
      style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark),
    );
  }
}

class _CheckNowButton extends StatelessWidget {
  const _CheckNowButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.navBarActive,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.open_in_new_rounded,
                size: 14.sp,
                color: Colors.white,
              ),
              SizedBox(width: 4.w),
              Text(
                'Check Now',
                style: AppTextStyles.buttonText.copyWith(fontSize: 11.sp),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
