import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

import '../../core/snackbar/app_snackbar.dart';
import '../../core/storage/app_storage.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/url_launcher_util.dart' show iosPurchaseDisclaimer;
import '../../core/widgets/detail_app_bar.dart';
import '../../../razorpay_service/razorpay_service.dart';
import '../../../api_services/services_api.dart';
import '../../../api_services/payments_api.dart';

class SubscriptionPlanView extends StatefulWidget {
  const SubscriptionPlanView({super.key});

  @override
  State<SubscriptionPlanView> createState() => _SubscriptionPlanViewState();
}

class _SubscriptionPlanViewState extends State<SubscriptionPlanView> {
  final RazorpayService _razorpayService = RazorpayService();
  String _selectedStream = 'UG';
  bool _isProcessingPayment = false;

  // Plans loaded from Services API. When null, fall back to static definitions below.
  List<_PlanModel>? _apiUgPlans;
  List<_PlanModel>? _apiPgPlans;
  bool _isLoadingPlans = false;
  String? _plansError;
  List<String> _availableStreams = const <String>['UG', 'PG'];
  _PlanModel? _lastPlan;
  String? _lastOrderId;

  static const List<_PlanModel> _ugPlans = <_PlanModel>[
    _PlanModel(
      id: 'ug_alert',
      stream: 'UG',
      title: 'NEET UG Counselling Alert Package',
      discountLabel: '80% OFF',
      originalPriceInPaise: 1000000,
      priceInPaise: 200000,
      savingsText: 'You save 80%',
      features: <_PlanFeature>[
        _PlanFeature('Instant Alerts & Notifications', true),
        _PlanFeature('All State Cutoff & Fees Updates', true),
        _PlanFeature('Round Wise Notifications', true),
        _PlanFeature('Seat Matrix Info', true),
        _PlanFeature('State Wise Counselling Alerts', true),
        _PlanFeature('State Wise Documents List', true),
        _PlanFeature('Priority List Provide', true),
        _PlanFeature('5-6 Online Counsellor Sessions', true),
        _PlanFeature('Unlimited NEET UG Support', false),
        _PlanFeature('Senior Counselor + Director Access', false),
      ],
    ),
    _PlanModel(
      id: 'ug_popular',
      stream: 'UG',
      title: 'Most Popular Counselling Package',
      discountLabel: '50% OFF',
      originalPriceInPaise: 5000000,
      priceInPaise: 2500000,
      savingsText: 'You save 50%',
      features: <_PlanFeature>[
        _PlanFeature('Dedicated Personal Counseling Support', true),
        _PlanFeature('Score-Based College Planning', true),
        _PlanFeature('3-Level Strategic Counseling Plan', true),
        _PlanFeature('24x7 Alerts & Notifications', true),
        _PlanFeature('Round-wise counseling support', true),
        _PlanFeature('Security Refund Status Tracking', true),
        _PlanFeature('Senior Counselor Access', true),
        _PlanFeature('Expert Q&A sessions', true),
        _PlanFeature('Post-counseling support', true),
        _PlanFeature('Unlimited NEET UG Support', true),
      ],
    ),
  ];

  static const List<_PlanModel> _pgPlans = <_PlanModel>[
    _PlanModel(
      id: 'pg_alert',
      stream: 'PG',
      title: 'NEET PG Counselling Alert Package',
      discountLabel: '80% OFF',
      originalPriceInPaise: 2000000,
      priceInPaise: 400000,
      savingsText: 'You save 80%',
      features: <_PlanFeature>[
        _PlanFeature('Instant Alerts & Notifications', true),
        _PlanFeature('All State Cutoff & Fees Updates', true),
        _PlanFeature('Round Wise Notifications', true),
        _PlanFeature('PG Seat Matrix Info', true),
        _PlanFeature('State Wise Counselling Alerts', true),
        _PlanFeature('State Wise Documents List', true),
        _PlanFeature('Priority List Provide', true),
        _PlanFeature('5-6 Online Counsellor Sessions', true),
        _PlanFeature('Unlimited NEET PG Support', false),
        _PlanFeature('Senior Counselor + Director Access', false),
      ],
    ),
    _PlanModel(
      id: 'pg_popular',
      stream: 'PG',
      title: 'Most Popular Counselling Package',
      discountLabel: '50% OFF',
      originalPriceInPaise: 5000000,
      priceInPaise: 2500000,
      savingsText: 'You save 50%',
      features: <_PlanFeature>[
        _PlanFeature('Dedicated Personal Counseling Support', true),
        _PlanFeature('Score-Based College Planning', true),
        _PlanFeature('4-Level Strategic Counseling Plan', true),
        _PlanFeature('24x7 Alerts & Notifications', true),
        _PlanFeature('Round-wise counseling support', true),
        _PlanFeature('Security Refund Status Tracking', true),
        _PlanFeature('Senior Counselor Access', true),
        _PlanFeature('Expert Q&A sessions', true),
        _PlanFeature('Post-counseling support', true),
        _PlanFeature('Unlimited NEET PG Support', true),
      ],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _razorpayService.init(
      onSuccess: _onPaymentSuccess,
      onError: _onPaymentError,
      onExternalWallet: _onExternalWallet,
    );
    _loadPlansFromApi();
  }

  @override
  void dispose() {
    _razorpayService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isIOS = !kIsWeb && Platform.isIOS;
    final List<_PlanModel> plans = _selectedStream == 'UG'
        ? (_apiUgPlans ?? _ugPlans)
        : (_apiPgPlans ?? _pgPlans);

    return Scaffold(
      backgroundColor: const Color(0xFFF1F3F5),
      appBar: DetailAppBar(
        title: 'Subscription Plans',
        subtitle: 'Choose your plan',
        hideFilter: true,
        onBack: () => Get.back(),
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(parent: ClampingScrollPhysics()),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          children: [
            _buildToggle(),
            SizedBox(height: 14.h),
            if (_isLoadingPlans && _apiUgPlans == null && _apiPgPlans == null)
              Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: const Center(child: CircularProgressIndicator()),
              ),
            if (_plansError != null)
              Padding(
                padding: EdgeInsets.only(bottom: 8.h),
                child: Text(
                  _plansError!,
                  style: AppTextStyles.bodyS.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.center,
                ),
              ),
            if (isIOS)
              Padding(
                padding: EdgeInsets.only(bottom: 10.h),
                child: Text(
                  iosPurchaseDisclaimer,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyS.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            for (int i = 0; i < plans.length; i++) ...[
              _buildPlanCard(plan: plans[i], isIOS: isIOS),
              if (i != plans.length - 1) SizedBox(height: 14.h),
            ],
            SizedBox(height: 12.h),
          ],
        ),
      ),
    );
  }

  Widget _buildToggle() {
    return Center(
      child: Container(
        width: 300.w,
        padding: EdgeInsets.all(2.w),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999.r),
          border: Border.all(color: const Color(0xFF0B8A83), width: 1),
          color: const Color(0xFFF7F9FB),
        ),
        child: Row(
          children: [
            for (final stream in _availableStreams) ...[
              Expanded(
                child: _ToggleTab(
                  text: stream,
                  selected: _selectedStream == stream,
                  onTap: () => setState(() => _selectedStream = stream),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard({
    required _PlanModel plan,
    required bool isIOS,
  }) {
    final String original = _formatRupees(plan.originalPriceInPaise ~/ 100);
    final String current = _formatRupees(plan.priceInPaise ~/ 100);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: const Color(0xFFD5DEE8)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F355D).withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildCardHeader(plan.title, plan.discountLabel),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 8.h, 14.w, 12.h),
            child: Column(
              children: [
                for (int i = 0; i < plan.features.length; i++) ...[
                  _buildFeatureRow(plan.features[i]),
                  if (i != plan.features.length - 1)
                    Divider(height: 10.h, color: const Color(0xFFEEF1F4)),
                ],
                SizedBox(height: 8.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      Text(
                        '\u20B9 $original',
                        style: AppTextStyles.bodyS.copyWith(
                          color: const Color(0xFF98A2AD),
                          decoration: TextDecoration.lineThrough,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        '\u20B9 $current + GST',
                        style: AppTextStyles.welcomeHeading.copyWith(
                          color: const Color(0xFF0069B2),
                          fontSize: 33.sp,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 10.h),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 7.h),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDFF2E2),
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      plan.savingsText,
                      style: AppTextStyles.bodyS.copyWith(
                        color: const Color(0xFF0A7A3F),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 12.h),
                if (!isIOS)
                  SizedBox(
                    width: double.infinity,
                    child: InkWell(
                      onTap: _isProcessingPayment ? null : () => _openRazorpay(plan),
                      borderRadius: BorderRadius.circular(24.r),
                      child: Container(
                        height: 42.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(24.r),
                          gradient: const LinearGradient(
                            colors: <Color>[Color(0xFF1377B2), Color(0xFF14B3C6)],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _isProcessingPayment ? 'Opening...' : 'Choose Plan',
                          style: AppTextStyles.buttonText.copyWith(fontSize: 13.sp),
                        ),
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

  Widget _buildCardHeader(String title, String discountLabel) {
    return SizedBox(
      height: 40.h,
      child: Stack(
        children: [
          Container(
            width: double.infinity,
            height: 40.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14.r)),
              gradient: const LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: <Color>[Color(0xFF0E75B2), Color(0xFF14B5C6)],
              ),
            ),
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text(
              title,
              style: AppTextStyles.welcomeHeading.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            child: ClipPath(
              clipper: _CornerRibbonClipper(),
              child: Container(
                width: 62.w,
                height: 62.w,
                color: const Color(0xFF4CB648),
                alignment: const Alignment(0.35, -0.25),
                child: Transform.rotate(
                  angle: 0.72,
                  child: Text(
                    discountLabel,
                    style: AppTextStyles.bodyS.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureRow(_PlanFeature feature) {
    return SizedBox(
      height: 32.h,
      child: Row(
        children: [
          Text(
            '.',
            style: AppTextStyles.bodyS.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.w700,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              feature.text,
              style: AppTextStyles.bodyS.copyWith(
                color: const Color(0xFF031A38),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Icon(
            feature.included ? Icons.check_circle : Icons.cancel,
            size: 17.sp,
            color: feature.included ? const Color(0xFF0B8A83) : const Color(0xFFE60000),
          ),
        ],
      ),
    );
  }

  String _formatRupees(int value) {
    final String input = value.toString();
    if (input.length <= 3) return input;
    final String last3 = input.substring(input.length - 3);
    String rest = input.substring(0, input.length - 3);
    final List<String> groups = <String>[];
    while (rest.length > 2) {
      groups.insert(0, rest.substring(rest.length - 2));
      rest = rest.substring(0, rest.length - 2);
    }
    if (rest.isNotEmpty) groups.insert(0, rest);
    return '${groups.join(',')},$last3';
  }

  Future<void> _loadPlansFromApi() async {
    setState(() {
      _isLoadingPlans = true;
      _plansError = null;
    });

    final (success, data, error) = await ServicesApi.getServices();
    if (!mounted) return;

    if (!success || data == null) {
      setState(() {
        _isLoadingPlans = false;
        _plansError = error;
      });
      return;
    }

    final List<_PlanModel> ug = <_PlanModel>[];
    final List<_PlanModel> pg = <_PlanModel>[];
    final List<String> streamsFromApi = <String>[];

    for (final type in data.courseTypes) {
      final stream = type.name.trim().toUpperCase();
      if (stream.isNotEmpty) streamsFromApi.add(stream);
      for (final plan in type.pricingPlans) {
        final bool isUg = stream == 'UG' || type.id == '1';
        final bool isPg = stream == 'PG' || type.id == '2';

        final discountLabel =
            plan.hasDiscount && plan.discount > 0 ? '${plan.discount}% OFF' : '';
        final savingsText = plan.hasDiscount && plan.discount > 0
            ? 'You save ${plan.discount}%'
            : 'No discount';

        final List<_PlanFeature> features = plan.points
            .map(
              (p) => _PlanFeature(
                p.text,
                // Treat check icon as included, xmark as not included.
                p.icon.toLowerCase().contains('check'),
              ),
            )
            .toList();

        final model = _PlanModel(
          id: plan.id,
          stream: isPg ? 'PG' : 'UG',
          title: plan.name.trim(),
          discountLabel: discountLabel,
          originalPriceInPaise: plan.price * 100,
          priceInPaise: plan.discountedPrice * 100,
          savingsText: savingsText,
          features: features,
        );

        if (isUg) {
          ug.add(model);
        } else if (isPg) {
          pg.add(model);
        }
      }
    }

    setState(() {
      _apiUgPlans = ug.isNotEmpty ? ug : null;
      _apiPgPlans = pg.isNotEmpty ? pg : null;
      _isLoadingPlans = false;
      _plansError = null;
      if (streamsFromApi.isNotEmpty) {
        _availableStreams = streamsFromApi.toSet().toList();
        if (!_availableStreams.contains(_selectedStream)) {
          _selectedStream = _availableStreams.first;
        }
      }
    });
  }

  void _openRazorpay(_PlanModel plan) {
    if (!_razorpayService.isInitialized) {
      AppSnackbar.error('Payment error', 'Payment service is not ready. Try again.');
      return;
    }
    setState(() => _isProcessingPayment = true);
    () async {
      try {
        // Plan price is stored in paise; convert to rupees for create-order API.
        final int amountInRupees = plan.priceInPaise ~/ 100;
        final (success, order, error) =
            await PaymentsApi.createOrder(amountInRupees: amountInRupees);

        if (!mounted) return;

        if (!success || order == null) {
          setState(() => _isProcessingPayment = false);
          AppSnackbar.error('Payment error', error ?? 'Failed to create order');
          return;
        }

        _lastOrderId = order.id;
        _lastPlan = plan;

        _razorpayService.openCheckout(
          amountInPaise: order.amount,
          orderId: order.id,
          planName: plan.title,
          description: '${plan.stream} subscription plan',
          contact: AppStorage.userPhone,
          email: AppStorage.userEmail,
          notes: <String, dynamic>{
            'plan_id': plan.id,
            'plan_stream': plan.stream,
            'plan_title': plan.title,
          },
        );
      } catch (e) {
        if (!mounted) return;
        setState(() => _isProcessingPayment = false);
        AppSnackbar.error('Payment failed', e.toString());
      }
    }();
  }

  void _onPaymentSuccess(PaymentSuccessResponse response) {
    if (mounted) setState(() => _isProcessingPayment = false);

    final plan = _lastPlan;
    final orderId = response.orderId ?? _lastOrderId ?? '';
    final paymentId = response.paymentId ?? '';
    final signature = response.signature ?? '';

    if (plan != null && orderId.isNotEmpty) {
      final firstName = (AppStorage.userFirstName ?? '').trim();
      final lastName = (AppStorage.userLastName ?? '').trim();
      final email = AppStorage.userEmail ?? '';
      final mobile = AppStorage.userPhone ?? '';
      final streamInt = plan.stream.toUpperCase() == 'PG' ? 2 : 1;
      final amountInRupees = plan.priceInPaise ~/ 100;
      final packageId = int.tryParse(plan.id) ?? 0;

      final payload = VerifyPaymentPayload(
        razorpayPaymentId: paymentId,
        razorpayOrderId: orderId,
        razorpaySignature: signature,
        firstName: firstName.isEmpty ? 'User' : firstName,
        lastName: lastName,
        email: email,
        mobile: mobile,
        stream: streamInt,
        amountInRupees: amountInRupees,
        packageId: packageId,
        paymentStatus: 1,
      );

      // Fire-and-forget; backend updates subscription.
      verifyPayment(payload);
    }

    AppSnackbar.success(
      'Payment successful',
      'Payment ID: ${response.paymentId ?? 'N/A'}',
    );
  }

  void _onPaymentError(PaymentFailureResponse response) {
    if (mounted) setState(() => _isProcessingPayment = false);

    final plan = _lastPlan;
    String orderId = _lastOrderId ?? '';
    String paymentId = '';

    final errorData = response.error;
    if (errorData is Map) {
      final metadata = errorData['metadata'];
      if (metadata is Map) {
        paymentId = metadata['payment_id']?.toString() ?? paymentId;
        orderId = metadata['order_id']?.toString() ?? orderId;
      }
    }

    if (plan != null && orderId.isNotEmpty) {
      final firstName = (AppStorage.userFirstName ?? '').trim();
      final lastName = (AppStorage.userLastName ?? '').trim();
      final email = AppStorage.userEmail ?? '';
      final mobile = AppStorage.userPhone ?? '';
      final streamInt = plan.stream.toUpperCase() == 'PG' ? 2 : 1;
      final amountInRupees = plan.priceInPaise ~/ 100;
      final packageId = int.tryParse(plan.id) ?? 0;

      final payload = VerifyPaymentPayload(
        razorpayPaymentId: paymentId,
        razorpayOrderId: orderId,
        razorpaySignature: '',
        firstName: firstName.isEmpty ? 'User' : firstName,
        lastName: lastName,
        email: email,
        mobile: mobile,
        stream: streamInt,
        amountInRupees: amountInRupees,
        packageId: packageId,
        paymentStatus: 0,
      );

      // Fire-and-forget failure logging.
      verifyPayment(payload);
    }

    final String message = response.message?.trim().isNotEmpty == true
        ? response.message!.trim()
        : 'Payment was cancelled or failed.';
    AppSnackbar.error('Payment failed', message);
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    if (mounted) setState(() => _isProcessingPayment = false);
    AppSnackbar.info(
      'External wallet selected',
      response.walletName ?? 'Wallet',
    );
  }
}

class _PlanModel {
  const _PlanModel({
    required this.id,
    required this.stream,
    required this.title,
    required this.discountLabel,
    required this.originalPriceInPaise,
    required this.priceInPaise,
    required this.savingsText,
    required this.features,
  });

  final String id;
  final String stream;
  final String title;
  final String discountLabel;
  final int originalPriceInPaise;
  final int priceInPaise;
  final String savingsText;
  final List<_PlanFeature> features;
}

class _PlanFeature {
  const _PlanFeature(this.text, this.included);

  final String text;
  final bool included;
}

class _ToggleTab extends StatelessWidget {
  const _ToggleTab({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final String text;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999.r),
      child: Container(
        height: 34.h,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF0B8A83) : Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodyM.copyWith(
            color: selected ? Colors.white : const Color(0xFF0B8A83),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _CornerRibbonClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final Path path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
