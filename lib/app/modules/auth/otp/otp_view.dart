import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_primary_button.dart';
import '../../../core/widgets/auth_brand_header.dart';
import 'otp_controller.dart';

class OtpView extends GetView<OtpController> {
  const OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, size: 22.sp, color: AppColors.textDark),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 12.h),
              const AuthBrandHeader(logoAsset: 'assets/auth/login-logo.png'),
              SizedBox(height: 32.h),
              Text('Verify OTP', style: AppTextStyles.authHeading.copyWith(fontSize: 22.sp)),
              SizedBox(height: 10.h),
              Obx(() => Text(
                    'Code sent to ${controller.phone.value.isEmpty ? "your number" : controller.phone.value}',
                    style: AppTextStyles.authSubheading.copyWith(fontSize: 12.sp),
                    textAlign: TextAlign.center,
                  )),
              SizedBox(height: 32.h),
             Pinput(
                    length: OtpController.otpLength,
                    controller: controller.pinputController,
                    focusNode: controller.pinputFocusNode,
                    defaultPinTheme: PinTheme(
                      width: 56.w,
                      height: 56.h,
                      textStyle: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.border, width: 1.5),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 56.w,
                      height: 56.h,
                      textStyle: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                    submittedPinTheme: PinTheme(
                      width: 56.w,
                      height: 56.h,
                      textStyle: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: AppColors.primaryBlue, width: 2),
                      ),
                    ),
                    errorPinTheme: PinTheme(
                      width: 56.w,
                      height: 56.h,
                      textStyle: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: Colors.red, width: 1.5),
                      ),
                    ),
                    pinputAutovalidateMode: PinputAutovalidateMode.onSubmit,
                    showCursor: true,
                    onCompleted: (pin) => controller.onSubmit(),
                    onChanged: (value) => controller.onOtpChanged(value),
                    keyboardType: TextInputType.number,
                  ),
              SizedBox(height: 28.h),
              Obx(() => AppPrimaryButton(
                    text: controller.isLoading.value ? 'Verifying...' : 'Verify & Continue',
                    onTap: controller.isLoading.value ? null : controller.onSubmit,
                    isDisabled: controller.isLoading.value,
                  )),
              SizedBox(height: 24.h),
              Obx(() => Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Didn't receive code? ",
                        style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                      ),
                      TextButton(
                        onPressed: controller.resendSeconds.value > 0 ? null : () { controller.onResendOtp(); },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          controller.resendSeconds.value > 0
                              ? 'Resend in ${controller.resendSeconds.value}s'
                              : 'Resend OTP',
                          style: AppTextStyles.bodyS.copyWith(
                            color: controller.resendSeconds.value > 0
                                ? AppColors.textMuted
                                : AppColors.primaryBlue,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }
}
