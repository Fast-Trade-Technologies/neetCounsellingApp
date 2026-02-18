import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_asset_image.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/auth_brand_header.dart';
import 'login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  static const String _illustrationAsset = 'assets/auth/login-asset.jpg';

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
              SizedBox(height: 18.h),
              AppAssetImage(
                _illustrationAsset,
                width: 320.w,
                height: (MediaQuery.sizeOf(context).height * 0.32)
                    .clamp(170.0, 260.0),
                fit: BoxFit.contain,
              ),
              SizedBox(height: 18.h),
              Text('Sign in to your account', style: AppTextStyles.authHeading),
              SizedBox(height: 4.h),
              Text(
                'Welcome back! Please sign in to continue.',
                style: AppTextStyles.authSubheading,
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 14.h),
              AppTextField(
                hintText: 'Enter Mobile Number',
                controller: controller.mobileController,
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.done,
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textMuted,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 14.h),
              AppPrimaryButton(text: 'Get OTP', onTap: () { controller.onGetOtp(); }),
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
              SizedBox(height: 18.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(
                    onTap: controller.onRegister,
                    child: Text(
                      'Register',
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: controller.onSkip,
                    child: Text(
                      'Skip',
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700,
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

