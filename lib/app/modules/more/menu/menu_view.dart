import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_asset_image.dart';
import '../../../core/widgets/detail_app_bar.dart';
import '../../../routes/app_routes.dart';
import 'menu_controller.dart';

class MenuView extends GetView<MoreMenuController> {
  const MenuView({super.key});

  static const String _profileAsset = 'assets/auth/login-asset.jpg';
  static const String _icons = 'assets/dashboard-icons';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chipBg,
      appBar: DetailAppBar(
        title: 'Menu',
        titleColor: AppColors.primaryBlue,
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refresh(),
        color: AppColors.primaryBlue,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
          child: Column(
            children: [
              _buildProfileCard(),
              SizedBox(height: 24.h),
              _buildMenuCard(context),
              SizedBox(height: 16.h),
              _buildLogoutTile(),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryBlue.withValues(alpha: 0.2),
                  blurRadius: 12,
                  spreadRadius: 0,
                ),
              ],
            ),
            child: ClipOval(
              child: AppAssetImage(
                _profileAsset,
                width: 88.w,
                height: 88.w,
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'Meet Kaur',
            style: AppTextStyles.welcomeHeading.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 6.h),
          Text(
            'meetkaur39@gmail.com',
            style: AppTextStyles.detailScreenSubtitle.copyWith(fontSize: 12.sp),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 8.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(20.r),
              border: Border.all(color: AppColors.chipBorder),
            ),
            child: Text(
              'NEET Counselling',
              style: AppTextStyles.label.copyWith(fontSize: 10.sp, color: AppColors.primaryBlue),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _MenuListTile(
            iconAsset: '$_icons/edit_profile.png',
            label: 'Edit Profile',
            onTap: () => Get.toNamed(AppRoutes.profile),
          ),
          _buildDivider(),
          _MenuListTile(
            iconAsset: '$_icons/About-Us.png',
            label: 'About Us',
            onTap: () {},
          ),
          _buildDivider(),
          _MenuListTile(
            iconAsset: '$_icons/Insights.png',
            label: 'Insights',
            onTap: () {},
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Divider(height: 1, color: AppColors.divider),
    );
  }

  Widget _buildLogoutTile() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        onTap: controller.onLogout,
        borderRadius: BorderRadius.circular(16.r),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.red.shade100),
            color: Colors.red.shade50,
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: Colors.red.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.logout_rounded, size: 24.sp, color: Colors.red.shade700),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  'Logout',
                  style: AppTextStyles.menuButtonLabel.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.red.shade700,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 22.sp, color: Colors.red.shade700),
            ],
          ),
        ),
      ),
    );
  }
}

class _MenuListTile extends StatelessWidget {
  const _MenuListTile({
    required this.label,
    this.iconAsset,
    this.icon,
    required this.onTap,
  }) : assert(icon != null || iconAsset != null);

  final String label;
  final String? iconAsset;
  final IconData? icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Widget leading = iconAsset != null
        ? Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: AppColors.chipBg,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.chipBorder),
            ),
            child: AppAssetImage(iconAsset!, width: 24.w, height: 24.w, fit: BoxFit.contain),
          )
        : Icon(icon ?? Icons.circle, size: 24.sp, color: AppColors.primaryBlue);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          child: Row(
            children: [
              leading,
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.menuButtonLabel.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              Icon(Icons.chevron_right_rounded, size: 24.sp, color: AppColors.textMuted),
            ],
          ),
        ),
      ),
    );
  }
}
