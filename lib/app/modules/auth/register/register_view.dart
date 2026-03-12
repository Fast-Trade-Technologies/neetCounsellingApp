import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_asset_image.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_brand_header.dart';
import 'register_controller.dart';

class RegisterView extends GetView<RegisterController> {
  const RegisterView({super.key});

  static const String _headerAsset = 'assets/auth/register-asst.jpg';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 14.h),
              const AuthBrandHeader(logoAsset: 'assets/auth/login-logo.png'),
              SizedBox(height: 14.h),
              AppAssetImage(
                _headerAsset,
                width: 160.w,
                height: 80.h,
                fit: BoxFit.contain,
              ),
              SizedBox(height: 8.h),
              Text('Create your account', style: AppTextStyles.authHeading),
              SizedBox(height: 4.h),
              Text(
                'Join us and start your journey today',
                style: AppTextStyles.authSubheading,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 14.h),
              AppTextField(
                hintText: 'First Name',
                controller: controller.firstNameController,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 10.h),
              AppTextField(
                hintText: 'Last Name',
                controller: controller.lastNameController,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 10.h),
              AppTextField(
                hintText: 'Email',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
              ),
              SizedBox(height: 10.h),
              AppTextField(
                hintText: 'Mobile Number',
                controller: controller.mobileController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 12.h),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Stream',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              SizedBox(height: 6.h),
              Obx(
                () => Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.setStream('1'),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: controller.selectedStream.value == '1' ? AppColors.chipBg : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: controller.selectedStream.value == '1'
                                  ? AppColors.primaryBlue
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 18.w,
                                height: 18.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: controller.selectedStream.value == '0'
                                        ? AppColors.primaryBlue
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 9.w,
                                    height: 9.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: controller.selectedStream.value == '1'
                                          ? AppColors.primaryBlue
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'UG',
                                style: AppTextStyles.bodyS.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: InkWell(
                        onTap: () => controller.setStream('2'),
                        borderRadius: BorderRadius.circular(10.r),
                        child: Container(
                          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.h),
                          decoration: BoxDecoration(
                            color: controller.selectedStream.value == '2' ? AppColors.chipBg : Colors.white,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: controller.selectedStream.value == '2'
                                  ? AppColors.primaryBlue
                                  : AppColors.border,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 18.w,
                                height: 18.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: controller.selectedStream.value == '1'
                                        ? AppColors.primaryBlue
                                        : AppColors.border,
                                    width: 1.5,
                                  ),
                                ),
                                child: Center(
                                  child: Container(
                                    width: 9.w,
                                    height: 9.w,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: controller.selectedStream.value == '2'
                                          ? AppColors.primaryBlue
                                          : Colors.transparent,
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                'PG',
                                style: AppTextStyles.bodyS.copyWith(
                                  color: AppColors.textDark,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 14.h),
              AppPrimaryButton(text: 'Sign up', onTap: () { controller.onSignUp(); }),
              // TODO: Uncomment below code for Google and Apple Sign-In functionality
              // SizedBox(height: 12.h),
              // const AuthOrDivider(),
              // SizedBox(height: 12.h),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              //     AppSocialButton(
              //       label: 'Google',
              //       iconAsset: 'assets/auth/google-icon.png',
              //       onTap: () {},
              //     ),
              //     AppSocialButton(
              //       label: 'Apple',
              //       iconAsset: 'assets/auth/IOS.png',
              //       onTap: () {},
              //     ),
              //   ],
              // ),
              SizedBox(height: 16.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Already have an account? ',
                    style: AppTextStyles.bodyS.copyWith(
                      color: AppColors.textMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  InkWell(
                    onTap: controller.onSignIn,
                    child: Text(
                      'Sign in',
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.linkBlue,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
            ],
          ),
        ),
      ),
    );
  }
}

