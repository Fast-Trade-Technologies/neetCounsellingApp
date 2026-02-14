import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../theme/app_colors.dart';
import '../../routes/app_routes.dart';

class DetailBottomNav extends StatelessWidget {
  const DetailBottomNav({
    super.key,
    required this.activeIndex,
    this.onTap,
  });

  final int activeIndex;
  final ValueChanged<int>? onTap;

  static const String _icons = 'assets/dashboard-icons';

  static const List<_Item> _items = [
    _Item(label: 'Dashboard', icon: Icons.home_rounded, iconAsset: '$_icons/news-update.png'),
    _Item(label: 'Analysis', icon: Icons.show_chart_rounded, iconAsset: '$_icons/past_year.png'),
    _Item(label: 'Tools', icon: Icons.build_rounded, iconAsset: '$_icons/cut-off.png'),
    _Item(label: 'Post-Exam', icon: Icons.school_rounded, iconAsset: '$_icons/SYCC-Report.png'),
    _Item(label: 'More', icon: Icons.more_horiz_rounded, iconAsset: '$_icons/Insights.png'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              _items.length,
              (i) =>               _NavItem(
                label: _items[i].label,
                icon: _items[i].icon,
                iconAsset: _items[i].iconAsset,
                isSelected: activeIndex == i,
                onTap: () {
                  if (onTap != null) {
                    onTap!(i);
                  } else {
                    _defaultOnTap(i);
                  }
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _defaultOnTap(int index) {
    if (index == 0) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    if (index == 1) {
      Get.offAllNamed(AppRoutes.analysisCollegeSeats);
      return;
    }
    if (index == 2) {
      Get.offAllNamed(AppRoutes.toolsCutoffAllotments);
      return;
    }
    if (index == 3) {
      Get.offAllNamed(AppRoutes.syccReport);
      return;
    }
    if (index == 4) {
      Get.offAllNamed(AppRoutes.moreMenu);
      return;
    }
  }
}

class _Item {
  const _Item({required this.label, required this.icon, this.iconAsset});
  final String label;
  final IconData icon;
  final String? iconAsset;
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.label,
    required this.icon,
    this.iconAsset,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final String? iconAsset;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.navBarActive : AppColors.detailNavInactive;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (iconAsset != null)
              SizedBox(
                width: 24.w,
                height: 24.w,
                child: Image.asset(
                  iconAsset!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => Icon(icon, size: 22.sp, color: color),
                ),
              )
            else
              Icon(icon, size: 22.sp, color: color),
            SizedBox(height: 4.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 9.sp,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
