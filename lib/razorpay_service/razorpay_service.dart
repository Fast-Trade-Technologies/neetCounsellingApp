import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorpayService {
  static const String defaultKey = String.fromEnvironment(
    'RAZORPAY_KEY',
    defaultValue: 'rzp_test_00k6GowBp2hYc3',
  );

  Razorpay? _razorpay;

  void init({
    required void Function(PaymentSuccessResponse response) onSuccess,
    required void Function(PaymentFailureResponse response) onError,
    void Function(ExternalWalletResponse response)? onExternalWallet,
  }) {
    _razorpay?.clear();
    _razorpay = Razorpay();

    _razorpay!.on(Razorpay.EVENT_PAYMENT_SUCCESS, onSuccess);
    _razorpay!.on(Razorpay.EVENT_PAYMENT_ERROR, onError);
    if (onExternalWallet != null) {
      _razorpay!.on(Razorpay.EVENT_EXTERNAL_WALLET, onExternalWallet);
    }
  }

  bool get isInitialized => _razorpay != null;

  void openCheckout({
    String key = defaultKey,
    required int amountInPaise,
    required String planName,
    required String description,
    String? contact,
    String? email,
    Map<String, dynamic>? notes,
  }) {
    final checkout = _razorpay;
    if (checkout == null) {
      throw StateError(
        'RazorpayService is not initialized. Call init() first.',
      );
    }

    final options = <String, dynamic>{
      'key': key,
      'amount': amountInPaise,
      'name': 'NEET Counselling',
      'description': description,
      'currency': 'INR',
      'prefill': {
        'contact': (contact ?? '').trim(),
        'email': (email ?? '').trim(),
      },
      'theme': {'color': '#1C5FAE'},
      'notes': notes ?? <String, dynamic>{'plan_name': planName},
    };

    checkout.open(options);
  }

  void dispose() {
    _razorpay?.clear();
    _razorpay = null;
  }
}
