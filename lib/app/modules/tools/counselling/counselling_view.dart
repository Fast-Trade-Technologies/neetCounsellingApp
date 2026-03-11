import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/snackbar/app_snackbar.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/url_launcher_util.dart';
import '../../../core/widgets/detail_app_bar.dart';
import 'counselling_controller.dart';

class CounsellingView extends GetView<CounsellingController> {
  const CounsellingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Counselling',
        subtitle: 'Neet Counselling / Tools / Counselling',
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
              _buildHeaderCard(),
              SizedBox(height: 14.h),
              _buildFilterRowCard(context),
              SizedBox(height: 16.h),
              _buildResultsSection(context),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Counselling',
                style: AppTextStyles.welcomeHeading.copyWith(fontSize: 14.sp),
              ),
              SizedBox(height: 4.h),
              Text(
                'Find authorities, counselling types, state types, and resources all in one place.',
                style: AppTextStyles.bodyM.copyWith(
                  color: const Color(0xFF47576B),
                  fontSize: 10.sp,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFilterRowCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFE6EDF5)),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Obx(() => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      label: 'Counselling Type',
                      value: controller.selectedCounsellingType.value,
                      items: controller.counsellingTypes,
                      onChanged: controller.setCounsellingType,
                      icon: Icons.account_balance_rounded,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: _FilterDropdown(
                      label: 'State Type',
                      value: controller.selectedStateType.value,
                      items: controller.stateTypes,
                      onChanged: controller.setStateType,
                      icon: Icons.category_rounded,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Expanded(
                    child: _FilterDropdown(
                      label: 'State',
                      value: controller.selectedState.value,
                      items: controller.states,
                      onChanged: controller.setState,
                      icon: Icons.location_on_rounded,
                    ),
                  ),
                  const Expanded(child: SizedBox()),
                ],
              ),
            ],
          )),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14.r),
      border: Border.all(color: AppColors.chipBorder, width: 1),
      boxShadow: [
        BoxShadow(
          color: AppColors.textDark.withValues(alpha: 0.04),
          blurRadius: 12,
          offset: const Offset(0, 3),
          spreadRadius: 0,
        ),
      ],
    );
  }


  Widget _buildResultsSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.list_alt_rounded,
                  color: AppColors.primaryBlue,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Obx(() {
                  final count = controller.filteredRows.length;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Showing Results',
                        style: AppTextStyles.welcomeHeading.copyWith(fontSize: 16.sp),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        count == 1 ? '$count counselling found' : '$count counsellings found',
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.textMuted,
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.border),
            ),
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'Search by name, state, or type...',
                hintStyle: AppTextStyles.fieldHint.copyWith(fontSize: 12.sp),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: AppColors.textMuted,
                  size: 20.sp,
                ),
                filled: true,
                fillColor: Colors.transparent,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
              ),
              style: AppTextStyles.bodyS.copyWith(color: AppColors.textDark, fontSize: 13.sp),
            ),
          ),
          SizedBox(height: 14.h),
          Obx(() {
            final list = controller.filteredRows;
            if (list.isEmpty) {
              return _buildEmptyState();
            }
            return Column(
              children: [
                for (int i = 0; i < list.length; i++) ...[
                  _CounsellingCard(row: list[i]),
                  if (i < list.length - 1) SizedBox(height: 12.h),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 20.w),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48.sp,
              color: AppColors.textMuted,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'No results found',
            style: AppTextStyles.welcomeHeading.copyWith(
              fontSize: 16.sp,
              color: AppColors.textDark,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Try adjusting your filters or search query',
            style: AppTextStyles.bodyS.copyWith(
              color: AppColors.textMuted,
              fontSize: 12.sp,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _CounsellingCard extends StatelessWidget {
  const _CounsellingCard({required this.row});

  final CounsellingRow row;

  void _onResourceTap(String? url, String label) {
    if (url != null && url.trim().isNotEmpty) {
      openLinkInBrowser(url);
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
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.chipBorder, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with number and title
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (row.sNo != null)
                Container(
                  width: 36.w,
                  height: 36.w,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Text(
                    '${row.sNo}',
                    style: AppTextStyles.bodyS.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              if (row.sNo != null) SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  row.name,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                    fontSize: 15.sp,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          SizedBox(height: 12.h),
          
          // Key Information Section
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: AppColors.chipBg.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              children: [
                _InfoRow(icon: Icons.location_on_rounded, label: 'State', value: row.state),
                SizedBox(height: 8.h),
                _InfoRow(icon: Icons.category_rounded, label: 'State Type', value: row.stateType),
                SizedBox(height: 8.h),
                _InfoRow(icon: Icons.account_balance_rounded, label: 'Counselling Type', value: row.counsellingType),
                if (row.round != null && row.round!.isNotEmpty) ...[
                  SizedBox(height: 8.h),
                  _InfoRow(icon: Icons.repeat_rounded, label: 'Round', value: row.round!),
                ],
              ],
            ),
          ),
          
          // Dates Section (if available)
          if (row.startDate != null || row.endDate != null) ...[
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.15)),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 16.sp,
                    color: AppColors.primaryBlue,
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (row.startDate != null && row.startDate!.isNotEmpty)
                          Text(
                            'Start: ${row.startDate}',
                            style: AppTextStyles.bodyS.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (row.endDate != null && row.endDate!.isNotEmpty) ...[
                          if (row.startDate != null && row.startDate!.isNotEmpty) SizedBox(height: 4.h),
                          Text(
                            'End: ${row.endDate}',
                            style: AppTextStyles.bodyS.copyWith(
                              fontSize: 12.sp,
                              color: AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // Resources Section
          if ((row.officialWebsiteUrl != null && row.officialWebsiteUrl!.isNotEmpty) ||
              (row.registrationUrl != null && row.registrationUrl!.isNotEmpty) ||
              (row.prospectsUrl != null && row.prospectsUrl!.isNotEmpty)) ...[
            SizedBox(height: 10.h),
            Text(
              'Resources',
              style: AppTextStyles.bodyS.copyWith(
                fontSize: 12.sp,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (row.officialWebsiteUrl != null && row.officialWebsiteUrl!.isNotEmpty)
                  _ResourceLink(
                    label: 'Official Website',
                    icon: Icons.language_rounded,
                    onTap: () => _onResourceTap(row.officialWebsiteUrl, 'Official Website'),
                  ),
                if (row.registrationUrl != null && row.registrationUrl!.isNotEmpty)
                  _ResourceLink(
                    label: 'Registration',
                    icon: Icons.app_registration_rounded,
                    onTap: () => _onResourceTap(row.registrationUrl, 'Registration'),
                  ),
                if (row.prospectsUrl != null && row.prospectsUrl!.isNotEmpty)
                  _ResourceLink(
                    label: 'Prospects',
                    icon: Icons.description_rounded,
                    onTap: () => _onResourceTap(row.prospectsUrl, 'Prospects'),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: AppColors.primaryBlue,
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Row(
            children: [
              Text(
                '$label: ',
                style: AppTextStyles.bodyS.copyWith(
                  fontSize: 12.sp,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Expanded(
                child: Text(
                  value,
                  style: AppTextStyles.bodyS.copyWith(
                    fontSize: 12.sp,
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ResourceLink extends StatelessWidget {
  const _ResourceLink({
    required this.label,
    required this.onTap,
    required this.icon,
  });

  final String label;
  final VoidCallback onTap;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: AppColors.primaryBlue,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryBlue.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18.sp,
                color: Colors.white,
              ),
              SizedBox(width: 8.w),
              Text(
                label,
                style: AppTextStyles.bodyS.copyWith(
                  fontSize: 13.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
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
    this.icon,
  });

  final String label;
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final displayValue =
        items.contains(value) ? value : (items.isNotEmpty ? items.first : '');
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 14.sp,
                color: AppColors.textMuted,
              ),
              SizedBox(width: 4.w),
            ],
            Text(
              label,
              style: AppTextStyles.bodyS.copyWith(
                fontSize: 11.sp,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
          decoration: BoxDecoration(
            color: AppColors.chipBg,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: displayValue,
              isExpanded: true,
              isDense: true,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 20.sp,
                color: AppColors.primaryBlue,
              ),
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
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
