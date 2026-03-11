import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_asset_image.dart';
import '../../../core/widgets/detail_app_bar.dart';
import '../../../core/widgets/profile_image.dart';
import '../../../routes/app_routes.dart';
import 'menu_controller.dart';

class MenuView extends GetView<MoreMenuController> {
  const MenuView({super.key});

  static const String _profileAsset = 'assets/auth/login-asset.jpg';
  static const String _icons = 'assets/dashboard-icons';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Column(
            children: [
              _buildProfileSection(),
              SizedBox(height: 32.h),
              _buildMenuGrid(context),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      ),
    );
  }

  /// Profile: circular image, name, email – centered like the image.
  Widget _buildProfileSection() {
    return Obx(() => Column(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.textDark.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ProfileImage(
                size: 200.w,
                placeholderAsset: _profileAsset,
                fit: BoxFit.cover,
                imageUrl: controller.userImageUrl.value.isEmpty ? null : controller.userImageUrl.value,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              controller.userName.value,
              style: AppTextStyles.welcomeHeading.copyWith(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6.h),
            Text(
              controller.userEmail.value,
              style: AppTextStyles.bodyS.copyWith(
                fontSize: 13.sp,
                color: AppColors.textDark,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ));
  }

  /// 2x2 grid: Edit Profile, Insights, About Us, Logout (Logout unchanged).
  Widget _buildMenuGrid(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: _MenuGridButton(
                iconAsset: '$_icons/edit_profile.png',
                label: 'Edit Profile',
                onTap: () => Get.toNamed(AppRoutes.profile),
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: _MenuGridButton(
              iconAsset: '$_icons/About-Us.png',
                label: 'About Us',
                onTap: () => Get.toNamed(AppRoutes.about),
              ),
            ),
          ],
        ),
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: _buildLogoutTile(),
            ),
          ],
        ),
      ],
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
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
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
                child: Icon(Icons.logout_rounded, size: 20.sp, color: Colors.red.shade700),
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

/// Rounded white button with icon + text for 2x2 menu grid (Edit Profile, Insights, About Us).
class _MenuGridButton extends StatelessWidget {
  const _MenuGridButton({
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
        ? AppAssetImage(iconAsset!, width: 20.w, height: 20.w, fit: BoxFit.contain)
        : Icon(icon ?? Icons.circle, size: 20.w, color: AppColors.primaryBlue);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      shadowColor: AppColors.textDark.withValues(alpha: 0.08),
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 16.h),
          child: Row(
            children: [
              leading,
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  label,
                  style: AppTextStyles.menuButtonLabel.copyWith(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
