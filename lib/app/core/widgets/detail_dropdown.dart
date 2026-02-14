import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class DetailDropdown extends StatelessWidget {
  const DetailDropdown({
    super.key,
    required this.label,
    this.value,
    this.items,
    this.onChanged,
  });

  final String label;
  final String? value;
  final List<String>? items;
  final ValueChanged<String?>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              value ?? label,
              style: (value != null
                      ? AppTextStyles.bodyS.copyWith(color: AppColors.textDark)
                      : AppTextStyles.fieldHint)
                  .copyWith(fontSize: 12.sp),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Icon(Icons.keyboard_arrow_down_rounded,
              size: 20.sp, color: AppColors.textMuted),
        ],
      ),
    );
  }
}
