import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

/// Reusable pagination bar: "Showing X–Y of Z", per-page dropdown, page numbers, prev/next buttons.
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
    this.currentPage,
    this.totalPages,
    this.onPageTap,
  });

  final String showingText;
  final int entriesPerPage;
  final List<int> entriesOptions;
  final ValueChanged<int> onEntriesPerPageChanged;
  final bool hasPreviousPage;
  final bool hasNextPage;
  final VoidCallback onPreviousPage;
  final VoidCallback onNextPage;
  final int? currentPage;
  final int? totalPages;
  final ValueChanged<int>? onPageTap;

  @override
  Widget build(BuildContext context) {
    final showPageNumbers = currentPage != null && totalPages != null && totalPages! > 0;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.chipBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  showingText,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textDark,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (showPageNumbers) ...[
                SizedBox(width: 12.w),
                Text(
                  'Page',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textMuted,
                    fontSize: 11.sp,
                  ),
                ),
                SizedBox(width: 6.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                  child: Text(
                    '$currentPage / $totalPages',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.primaryBlue,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: AppColors.chipBg,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 60.w,
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: entriesOptions.contains(entriesPerPage)
                                ? entriesPerPage
                                : entriesOptions.first,
                            isExpanded: true,
                            isDense: true,
                            icon: Icon(
                              Icons.keyboard_arrow_down_rounded,
                              size: 18.sp,
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
                      SizedBox(width: 6.w),
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
              ),
              SizedBox(width: 12.w),
              _PageButton(
                icon: Icons.chevron_left_rounded,
                enabled: hasPreviousPage,
                onTap: onPreviousPage,
              ),
              if (showPageNumbers && onPageTap != null) ...[
                SizedBox(width: 8.w),
                _buildPageNumbers(context),
                SizedBox(width: 8.w),
              ],
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

  Widget _buildPageNumbers(BuildContext context) {
    if (currentPage == null || totalPages == null || totalPages! <= 1) return const SizedBox.shrink();
    final current = currentPage!;
    final total = totalPages!;
    
    // Show max 5 page numbers: current ± 2, or adjust if near start/end
    final pages = <int>[];
    if (total <= 5) {
      for (int i = 1; i <= total; i++) pages.add(i);
    } else {
      int start = (current - 2).clamp(1, total - 4);
      int end = (start + 4).clamp(5, total);
      for (int i = start; i <= end; i++) pages.add(i);
    }
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final page in pages) ...[
          if (page != pages.first) SizedBox(width: 4.w),
          _PageNumberButton(
            page: page,
            isActive: page == current,
            onTap: () => onPageTap?.call(page),
          ),
        ],
      ],
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
          ? AppColors.primaryBlue.withValues(alpha: 0.1)
          : AppColors.chipBg,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10.r),
        child: Container(
          width: 40.w,
          height: 40.w,
          alignment: Alignment.center,
          decoration: enabled
              ? BoxDecoration(
                  border: Border.all(color: AppColors.primaryBlue.withValues(alpha: 0.3)),
                  borderRadius: BorderRadius.circular(10.r),
                )
              : null,
          child: Icon(
            icon,
            size: 22.sp,
            color: enabled ? AppColors.primaryBlue : AppColors.textMuted,
          ),
        ),
      ),
    );
  }
}

class _PageNumberButton extends StatelessWidget {
  const _PageNumberButton({
    required this.page,
    required this.isActive,
    required this.onTap,
  });

  final int page;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isActive
          ? AppColors.primaryBlue
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          width: 32.w,
          height: 32.w,
          alignment: Alignment.center,
          decoration: isActive
              ? null
              : BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8.r),
                ),
          child: Text(
            '$page',
            style: AppTextStyles.bodyS.copyWith(
              color: isActive ? Colors.white : AppColors.textDark,
              fontSize: 12.sp,
              fontWeight: isActive ? FontWeight.w700 : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
