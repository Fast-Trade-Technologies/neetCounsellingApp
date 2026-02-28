import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/detail_app_bar.dart';

class SubscriptionPlanView extends StatefulWidget {
  const SubscriptionPlanView({super.key});

  @override
  State<SubscriptionPlanView> createState() => _SubscriptionPlanViewState();
}

class _SubscriptionPlanViewState extends State<SubscriptionPlanView> {
  String selectedPlan = 'UG';
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    _initializeRazorPay();
  }

  @override
  void dispose() {
    _razorpay.clear();
    super.dispose();
  }

  void _initializeRazorPay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: DetailAppBar(
        title: 'Subscription Plans',
        subtitle: 'Choose best plan for your needs',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Transparent Pricing. Defined Goals.',
              style: AppTextStyles.welcomeHeading.copyWith(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 20.h),
            
            // Plan Type Toggle
            Container(
              height: 48.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedPlan = 'UG'),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: selectedPlan == 'UG' ? AppColors.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: Center(
                          child: Text(
                            'UG',
                            style: AppTextStyles.bodyS.copyWith(
                              color: selectedPlan == 'UG' ? Colors.white : AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedPlan = 'PG'),
                      child: Container(
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: selectedPlan == 'PG' ? AppColors.primaryBlue : Colors.transparent,
                          borderRadius: BorderRadius.circular(25.r),
                        ),
                        child: Center(
                          child: Text(
                            'PG',
                            style: AppTextStyles.bodyS.copyWith(
                              color: selectedPlan == 'PG' ? Colors.white : AppColors.textDark,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            
            // Pricing Cards
            Column(
              children: [
                if (selectedPlan == 'UG') ...[
                  _buildUGAlertPackage(),
                  SizedBox(height: 16.w),
                  _buildPopularPackage(),
                ] else ...[
                  // PG Plans (placeholder for now)
                  Center(
                    child: Text(
                      'PG Plans Coming Soon',
                      style: AppTextStyles.bodyS.copyWith(
                        color: AppColors.textMuted,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUGAlertPackage() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.chipBorder),
        boxShadow: [
          BoxShadow(
            color: AppColors.textDark.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Discount Ribbon
          Positioned(
            top: 12,
            right: -30,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  bottomLeft: Radius.circular(4.r),
                ),
              ),
              child: Text(
                '80% OFF',
                style: AppTextStyles.bodyS.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NEET UG Counselling\nAlert Package',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 20.h),
                
                // Features
                _buildFeatureItem('Instant Alerts & Notifications', true),
                _buildFeatureItem('All State Cutoff & Fees Updates', true),
                _buildFeatureItem('Round Wise Notifications', true),
                _buildFeatureItem('Seat Matrix Info', true),
                _buildFeatureItem('State Wise Counselling Alerts', true),
                _buildFeatureItem('State Wise Documents List', true),
                _buildFeatureItem('Priority List Provide', true),
                _buildFeatureItem('5-6 Online Counsellor Sessions', true),
                _buildFeatureItem('Unlimited NEET UG Support', false),
                _buildFeatureItem('Senior Counselor + Director Access', false),
                
                SizedBox(height: 20.h),
                
                // Pricing Section
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      // Original Price
                      Text(
                        '₹10,000',
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      
                      // Current Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '₹',
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w300,
                              fontSize: 20.sp,
                            ),
                          ),
                          Text(
                            '2,000',
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 28.sp,
                            ),
                          ),
                          Text(
                            ' + GST',
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      
                      // Savings Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'You save 80%',
                          style: AppTextStyles.bodyS.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                
                // Choose Plan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _initiatePayment('UG_ALERT', 2000),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Choose Plan',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPopularPackage() {
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: AppColors.primaryBlue, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlue.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Discount Ribbon
          Positioned(
            top: 12,
            right: -30,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(4.r),
                  bottomLeft: Radius.circular(4.r),
                ),
              ),
              child: Text(
                '50% OFF',
                style: AppTextStyles.bodyS.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
          
          // Popular Badge
          Positioned(
            top: -10,
            left: 20,
            right: 20,
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Text(
                'Most Popular',
                style: AppTextStyles.bodyS.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10.sp,
                ),
              ),
            ),
          ),
          
          // Content
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20.h), // Space for badge
                Text(
                  'Most Popular\nCounselling Package',
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 16.sp,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 20.h),
                
                // Features
                _buildFeatureItem('Dedicated Personal Counseling Support', true),
                _buildFeatureItem('Score-Based College Planning', true),
                _buildFeatureItem('3-Level Strategic Counseling Plan', true),
                _buildFeatureItem('24x7 Alerts & Notifications', true),
                _buildFeatureItem('Round-wise counseling support', true),
                _buildFeatureItem('Security Refund Status Tracking', true),
                _buildFeatureItem('Senior Counselor Access', true),
                _buildFeatureItem('Expert Q&A sessions', true),
                _buildFeatureItem('Post-counseling support', true),
                _buildFeatureItem('Unlimited NEET UG Support', true),
                
                SizedBox(height: 20.h),
                
                // Pricing Section
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    color: AppColors.background.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    children: [
                      // Original Price
                      Text(
                        '₹50,000',
                        style: AppTextStyles.bodyS.copyWith(
                          color: AppColors.textMuted,
                          decoration: TextDecoration.lineThrough,
                          fontSize: 16.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      
                      // Current Price
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '₹',
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w300,
                              fontSize: 20.sp,
                            ),
                          ),
                          Text(
                            '25,000',
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                              fontSize: 28.sp,
                            ),
                          ),
                          Text(
                            ' + GST',
                            style: AppTextStyles.bodyS.copyWith(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.w500,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      
                      // Savings Badge
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                        decoration: BoxDecoration(
                          color: Colors.green.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          'You save 50%',
                          style: AppTextStyles.bodyS.copyWith(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                            fontSize: 12.sp,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                
                // Choose Plan Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _initiatePayment('POPULAR', 25000),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 16.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Choose Plan',
                      style: AppTextStyles.buttonText.copyWith(fontSize: 14.sp),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(String text, bool isIncluded) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24.w,
            height: 24.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isIncluded ? Colors.green.withValues(alpha: 0.15) : Colors.red.withValues(alpha: 0.15),
              shape: BoxShape.circle,
              border: Border.all(
                color: isIncluded ? Colors.green.withValues(alpha: 0.3) : Colors.red.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: isIncluded
                ? Icon(Icons.check_rounded, size: 16.sp, color: Colors.green)
                : Icon(Icons.close_rounded, size: 16.sp, color: Colors.red),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              text,
              style: AppTextStyles.bodyS.copyWith(
                color: AppColors.textDark,
                fontSize: 13.sp,
                height: 1.4,
                fontWeight: isIncluded ? FontWeight.w500 : FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _initiatePayment(String planId, int amount) {
    // Calculate amount in paise (Razor Pay uses smallest currency unit)
    int amountInPaise = amount * 100;
    
    // Create options for Razor Pay
    var options = {
      'key': 'rzp_test_1DP5mmOlF5GtT', // Test key - replace with your live key
      'amount': amountInPaise,
      'name': 'NEET Counselling',
      'description': '$planId Subscription Plan',
      'prefill': {
        'contact': '',
        'email': '',
      },
      'theme': {
        'color': '#1976D2' // AppColors.primaryBlue
      }
    };
    
    try {
      _razorpay.open(options);
    } catch (e) {
      Get.snackbar(
        'Payment Error',
        'Failed to initiate payment: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Get.snackbar(
      'Payment Successful',
      'Payment ID: ${response.paymentId}',
      backgroundColor: Colors.green,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
    
    // TODO: Update subscription status in your app
    // You might want to:
    // 1. Save subscription details to local storage
    // 2. Update user's subscription status in your backend
    // 3. Navigate to a success page or back to main app
    
    // For now, let's just show success and go back
    Future.delayed(const Duration(seconds: 2), () {
      Get.back();
    });
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Failed',
      'Error: ${response.message}\nCode: ${response.code}',
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 3),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'External Wallet',
      'Wallet: ${response.walletName}',
      backgroundColor: AppColors.primaryBlue,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }
}
