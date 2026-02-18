import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable pagination bar: "Showing X–Y of Z", per-page dropdown, prev/next buttons.
class PaginationBar extends StatelessWidget {
  const PaginationBar({
    super.key,
    required this.showingText,
    required this.entriesPerPage,
    required this.entriesOptions,
    required this.onEntriesPerPageChanged,
    required this.hasPreviousPage,
    required this.hasNextPage,
    required this.onPreviousPage,
    required this.onNextPage,
  });

  final String showingText;
  final int entriesPerPage;
  final List<int> entriesOptions;
  final ValueChanged<int> onEntriesPerPageChanged;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.chipBg,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.chipBorder),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              showingText,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                fontSize: 12.sp,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 56.w,
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<int>(
                          value: entriesOptions.contains(entriesPerPage)
                              ? entriesPerPage
                              : entriesOptions.first,
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
                          items: entriesOptions
                              .map((e) => DropdownMenuItem<int>(
                                    value: e,
                                    child: Text('$e'),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            if (v != null) onEntriesPerPageChanged(v);
                          },
                        ),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'per page',
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 11.sp,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              _PageButton(
                icon: Icons.chevron_left_rounded,
                enabled: hasPreviousPage,
                onTap: onPreviousPage,
              ),
              SizedBox(width: 6.w),
              _PageButton(
                icon: Icons.chevron_right_rounded,
                enabled: hasNextPage,
                onTap: onNextPage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PageButton extends StatelessWidget {
  const _PageButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: enabled
          ? AppColors.primaryBlue.withValues(alpha: 0.12)
          : AppColors.divider,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10.r),
        child: SizedBox(
          width: 40.w,
          height: 40.w,
          child: Icon(
            icon,
            size: 24.sp,
            color: enabled ? AppColors.primaryBlue : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}
