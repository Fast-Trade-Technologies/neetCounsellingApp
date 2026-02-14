import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_asset_image.dart';
import '../../../core/widgets/detail_app_bar.dart';
import 'menu_controller.dart';

class MenuView extends GetView<MoreMenuController> {
  const MenuView({super.key});

  static const String _profileAsset = 'assets/auth/login-asset.jpg';
  static const String _icons = 'assets/dashboard-icons';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Menu',
        titleColor: AppColors.primaryBlue,
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Column(
          children: [
            _buildProfileSection(),
            SizedBox(height: 24.h),
            _buildMenuGrid(context),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Column(
      children: [
        ClipOval(
          child: AppAssetImage(
            _profileAsset,
            width: 100.w,
            height: 100.w,
            fit: BoxFit.cover,
          ),
        ),
        SizedBox(height: 12.h),
        Text(
          'Meet Kaur',
          style: AppTextStyles.welcomeHeading.copyWith(fontSize: 18.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          'MeetKaur88@gmail.com',
          style: AppTextStyles.detailScreenSubtitle,
        ),
      ],
    );
  }

  Widget _buildMenuGrid(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            children: [
              _MenuTile(
                label: 'Edit Profile',
                iconAsset: '$_icons/edit_profile.png',
                onTap: () {},
              ),
              SizedBox(height: 12.h),
              _MenuTile(
                label: 'About Us',
                iconAsset: '$_icons/About-Us.png',
                onTap: () {},
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            children: [
              _MenuTile(
                label: 'Insights',
                iconAsset: '$_icons/Insights.png',
                onTap: () {},
              ),
              SizedBox(height: 12.h),
              _MenuTile(
                label: 'Logout',
                iconAsset: '$_icons/logout.png',
                onTap: controller.onLogout,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.label,
    this.icon,
    this.iconAsset,
    required this.onTap,
  }) : assert(icon != null || iconAsset != null);

  final String label;
  final IconData? icon;
  final String? iconAsset;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget iconWidget = iconAsset != null
        ? AppAssetImage(
            iconAsset!,
            width: 40.w,
            height: 40.w,
            fit: BoxFit.contain,
          )
        : Icon(icon ?? Icons.circle, size: 36.sp, color: AppColors.primaryBlue);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 12.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.chipBorder),
          ),
          child: Column(
            children: [
              iconWidget,
              SizedBox(height: 10.h),
              Text(
                label,
                style: AppTextStyles.menuButtonLabel,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
