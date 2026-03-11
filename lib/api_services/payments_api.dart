import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';
import 'base_api.dart';

class PaymentsApi {
  PaymentsApi._();

  static const String createOrderPath = '/payments/create-order';
  static const String verifyPaymentPath = '/payments/verify-payment.php';
  static final BaseAPI _api = BaseAPI();

  /// Creates a Razorpay order on the backend.
  ///
  /// [amountInRupees] should match the final plan price (e.g. 2000 => ₹2000).
  /// Returns (success, order, errorMessage).
  static Future<(bool success, RazorpayOrder? order, String? errorMessage)>
      createOrder({
    required int amountInRupees,
    bool showLoader = true,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to create an order');
    }

    try {
      final Response? response = await _api.post(
        url: createOrderPath,
        data: <String, dynamic>{
          'amount': amountInRupees,
          'nLoginUserIdNo': int.tryParse(userId) ?? userId,
        },
        showLoader: showLoader,
        skipAuth: true,
      );

      if (response == null) {
        return (false, null, 'No response from server');
      }
      if (response.statusCode != 200 && response.statusCode != 201) {
        return (false, null, 'Failed to create order');
      }

      final body = _parseBody(response.data);
      if (body == null) {
        return (false, null, 'Invalid order response');
      }

      final status = body['status']?.toString();
      final id = body['id']?.toString();
      final amount = body['amount'];
      final currency = body['currency']?.toString() ?? 'INR';

      if (status == null || id == null || amount == null) {
        return (false, null, 'Invalid order response');
      }

      final order = RazorpayOrder(
        id: id,
        status: status,
        amount: amount is int ? amount : int.tryParse(amount.toString()) ?? 0,
        currency: currency,
      );

      return (true, order, null);
    } on DioException catch (e) {
      final msg = e.message ?? 'Something went wrong';
      return (false, null, msg);
    } catch (e) {
      return (false, null, e.toString());
    }
  }

  static Map<String, dynamic>? _parseBody(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}

class RazorpayOrder {
  RazorpayOrder({
    required this.id,
    required this.status,
    required this.amount,
    required this.currency,
  });

  final String id;
  final String status;
  /// Amount in paise (as returned by backend and Razorpay order).
  final int amount;
  final String currency;
}

class VerifyPaymentPayload {
  VerifyPaymentPayload({
    required this.razorpayPaymentId,
    required this.razorpayOrderId,
    required this.razorpaySignature,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.mobile,
    required this.stream,
    required this.amountInRupees,
    required this.packageId,
    required this.paymentStatus,
  });

  final String razorpayPaymentId;
  final String razorpayOrderId;
  final String razorpaySignature;
  final String firstName;
  final String lastName;
  final String email;
  final String mobile;
  /// 1 = UG, 2 = PG (per backend contract)
  final int stream;
  final int amountInRupees;
  final int packageId;
  /// 1 = success, 0 = failure
  final int paymentStatus;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'mobile': mobile,
      'stream': stream,
      'amount': amountInRupees,
      'package_id': packageId,
      'payment_status': paymentStatus,
    };
  }
}

/// Hits /payments/verify-payment after success or failure.
/// For failures, [razorpay_payment_id] or [razorpay_signature] may be empty.
Future<(bool success, String? errorMessage)> verifyPayment(
  VerifyPaymentPayload payload, {
  bool showLoader = false,
}) async {
  try {
    final Response? response = await PaymentsApi._api.post(
      url: PaymentsApi.verifyPaymentPath,
      data: payload.toJson(),
      showLoader: showLoader,
      skipAuth: true,
    );

    if (response == null) {
      return (false, 'No response from server');
    }
    if (response.statusCode != 200 && response.statusCode != 201) {
      return (false, 'Failed to verify payment');
    }

    // We don't enforce response body structure; assume backend logs and updates status.
    return (true, null);
  } on DioException catch (e) {
    final msg = e.message ?? 'Something went wrong';
    return (false, msg);
  } catch (e) {
    return (false, e.toString());
  }
}


