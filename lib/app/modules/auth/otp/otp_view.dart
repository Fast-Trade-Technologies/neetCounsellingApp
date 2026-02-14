import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

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
              _OtpPinBoxes(controller: controller),
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
                        onPressed: controller.resendSeconds.value > 0 ? null : controller.onResendOtp,
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

class _OtpPinBoxes extends StatelessWidget {
  const _OtpPinBoxes({required this.controller});

  final OtpController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(
        OtpController.otpLength,
        (index) => _OtpBox(
          index: index,
          controller: controller.pinControllers[index],
          focusNode: controller.focusNodes[index],
          onChanged: (v) {
            if (v.length == 1) controller.onOtpDigitChanged(index, v);
            if (v.isEmpty) controller.onOtpKeyBackspace(index);
          },
          onSubmit: controller.onSubmit,
        ),
      ),
    );
  }
}

class _OtpBox extends StatelessWidget {
  const _OtpBox({
    required this.index,
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onSubmit,
  });

  final int index;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 46.w,
      height: 54.h,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        style: TextStyle(
          fontSize: 22.sp,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        onSubmitted: (_) => onSubmit(),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.border, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: AppColors.primaryBlue, width: 2),
          ),
        ),
      ),
    );
  }
}
