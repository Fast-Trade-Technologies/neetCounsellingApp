import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/detail_app_bar.dart';
import 'universities_institutes_controller.dart';

class UniversitiesInstitutesView extends GetView<UniversitiesInstitutesController> {
  const UniversitiesInstitutesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Universities & Institutes',
        subtitle: 'Neet Counselling / Tools / Universities & Institutes',
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
                'Access college-specific important counselling links & resources to ease your NEET Counselling journey!',
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
            'Necessary particulars of medical institutes of your desired universities.',
            style: AppTextStyles.detailScreenSubtitle.copyWith(color: AppColors.textDark),
          ),
          SizedBox(height: 14.h),
          Obx(() => Column(
            children: [
              Row(children: [Expanded(child: _FilterDropdown(label: 'State', value: controller.selectedState.value, items: UniversitiesInstitutesController.states, onChanged: controller.setState)), SizedBox(width: 10.w), Expanded(child: _FilterDropdown(label: 'Institute Type', value: controller.selectedInstituteType.value, items: UniversitiesInstitutesController.instituteTypes, onChanged: controller.setInstituteType))]),
              SizedBox(height: 10.h),
              Row(children: [Expanded(child: _FilterDropdown(label: 'University', value: controller.selectedUniversity.value, items: UniversitiesInstitutesController.universities, onChanged: controller.setUniversity))]),
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
          SizedBox(height: 12.h),
          Obx(() {
            final list = controller.filteredRows;
            if (list.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                child: Text(
                  'No results found.',
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                ),
              );
            }
            return Column(
              children: [
                for (int i = 0; i < list.length; i++) ...[
                  _InstituteCard(row: list[i]),
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

class _InstituteCard extends StatelessWidget {
  const _InstituteCard({required this.row});

  final UniversitiesInstitutesRow row;

  void _onResourceTap(String? url, String label) {
    if (url != null && url.isNotEmpty) {
      AppSnackbar.info(label, 'Link will open in browser when configured.');
    } else {
      AppSnackbar.warning(label, 'No link available for this resource.');
    }
  }

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
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _Chip(label: 'University', value: row.university),
                        _Chip(label: 'Authority', value: row.authority),
                        _Chip(label: 'Bond', value: row.bondPenalty),
                        _Chip(label: 'Beds', value: row.bedsCount),
                      ],
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 8.w,
                      runSpacing: 6.h,
                      children: [
                        _ResourceLink(
                          label: 'Official Website',
                          onTap: () => _onResourceTap(row.officialWebsiteUrl, 'Official Website'),
                        ),
                        _ResourceLink(
                          label: 'Registration',
                          onTap: () => _onResourceTap(row.registrationUrl, 'Registration'),
                        ),
                        _ResourceLink(
                          label: 'Prospects',
                          onTap: () => _onResourceTap(row.prospectsUrl, 'Prospects'),
                        ),
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

class _ResourceLink extends StatelessWidget {
  const _ResourceLink({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(6.r),
            border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.4)),
          ),
          child: Text(
            label,
            style: AppTextStyles.bodyS.copyWith(
              fontSize: 11.sp,
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
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
