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

