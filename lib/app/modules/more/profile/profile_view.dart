import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/detail_app_bar.dart';
import '../../../core/widgets/profile_image.dart';
import 'profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  static const String _profileAsset = 'assets/auth/login-asset.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.chipBg,
      appBar: DetailAppBar(
        title: 'Profile',
        subtitle: 'NEET Counselling / Profile',
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
          child: Obx(() {
            if (controller.isLoading.value && controller.firstNameController.text.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 100.h),
                child: const Center(child: CircularProgressIndicator()),
              );
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileSummary(),
                SizedBox(height: 20.h),
                _buildProfileTab(),
                SizedBox(height: 16.h),
                if (controller.error.value.isNotEmpty && controller.firstNameController.text.isEmpty)
                  Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Text(
                        controller.error.value,
                        style: AppTextStyles.bodyS.copyWith(color: Colors.red.shade700),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                _buildPersonalInfoCard(),
                SizedBox(height: 24.h),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildProfileAvatar() {
    final picked = controller.pickedImagePath.value.trim();
    if (picked.isNotEmpty) {
      final file = File(picked);
      if (file.existsSync()) {
        return ClipOval(
          child: Image.file(
            file,
            width: 80.w,
            height: 80.w,
            fit: BoxFit.cover,
          ),
        );
      }
    }
    return ProfileImage(
      size: 80.w,
      placeholderAsset: _profileAsset,
      fit: BoxFit.cover,
      imageUrl: controller.imageUrl.value.isEmpty ? null : controller.imageUrl.value,
    );
  }

  Widget _buildProfileSummary() {
    return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Obx(() => GestureDetector(
              onTap: controller.pickImage,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          blurRadius: 10,
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: _buildProfileAvatar(),
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: AppColors.primaryBlue,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Icon(Icons.camera_alt_rounded, size: 14.sp, color: Colors.white),
                    ),
                  ),
                ],
              ),
            )),
            SizedBox(width: 20.w),
            Expanded(
              child: Obx(() => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    controller.displayName.value,
                    style: AppTextStyles.welcomeHeading.copyWith(fontSize: 18.sp, fontWeight: FontWeight.w700),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    'Explore - NEET UG',
                    style: AppTextStyles.detailScreenSubtitle.copyWith(fontSize: 12.sp),
                  ),
                  SizedBox(height: 14.h),
                  Row(
                    children: [
                      Icon(Icons.phone_rounded, size: 16.sp, color: AppColors.textMuted),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Phone : ${controller.displayPhone.value}',
                          style: AppTextStyles.bodyS.copyWith(fontSize: 12.sp, color: AppColors.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(Icons.email_rounded, size: 16.sp, color: AppColors.textMuted),
                      SizedBox(width: 8.w),
                      Expanded(
                        child: Text(
                          'Email : ${controller.displayEmail.value}',
                          style: AppTextStyles.bodyS.copyWith(fontSize: 12.sp, color: AppColors.textDark),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              )),
            ),
          ],
        ),
      );
  }

  Widget _buildProfileTab() {
    return Container(
      padding: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: AppColors.primaryBlue, width: 2.5),
        ),
      ),
      child: Text(
        'Profile',
        style: AppTextStyles.welcomeHeading.copyWith(
          fontSize: 15.sp,
          color: AppColors.primaryBlue,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personal Information',
            style: AppTextStyles.welcomeHeading.copyWith(fontSize: 16.sp),
          ),
          SizedBox(height: 20.h),
          _LabeledField(label: 'First Name', child: TextField(
            controller: controller.firstNameController,
            textInputAction: TextInputAction.next,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.textDark),
            decoration: _inputDecoration(hint: 'First name'),
          )),
          SizedBox(height: 16.h),
          _LabeledField(label: 'Last Name', child: TextField(
            controller: controller.lastNameController,
            textInputAction: TextInputAction.next,
            style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.textDark),
            decoration: _inputDecoration(hint: 'Last name'),
          )),
          SizedBox(height: 16.h),
          _LabeledField(
            label: 'Contact Phone',
            icon: Icons.phone_rounded,
            child: TextField(
              controller: controller.phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.textDark),
              decoration: _inputDecoration(hint: '10-digit mobile number'),
            ),
          ),
          SizedBox(height: 16.h),
          _LabeledField(
            label: 'Email Address',
            icon: Icons.alternate_email_rounded,
            child: TextField(
              controller: controller.emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500, color: AppColors.textDark),
              decoration: _inputDecoration(hint: 'Email address'),
            ),
          ),
          SizedBox(height: 24.h),
          Obx(() => SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              text: controller.isUpdating.value ? 'Updating...' : 'Submit',
              onTap: controller.isUpdating.value ? null : controller.onSubmit,
            ),
          )),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({required String hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.fieldHint.copyWith(fontSize: 12.sp),
      isDense: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
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
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.r),
        borderSide: const BorderSide(color: AppColors.primaryBlue, width: 1.5),
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({required this.label, required this.child, this.icon});

  final String label;
  final Widget child;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[
              Icon(icon, size: 16.sp, color: AppColors.textMuted),
              SizedBox(width: 6.w),
            ],
            Text(
              label,
              style: AppTextStyles.detailScreenSubtitle.copyWith(
                fontSize: 12.sp,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        child,
      ],
    );
  }
}
