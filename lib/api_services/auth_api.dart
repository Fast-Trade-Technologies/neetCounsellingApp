import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

import 'base_api.dart';

/// Auth API from NEET Counseling API Postman collection.
/// Login (WhatsApp OTP): POST {{base_url}}/auth/login
///   Body: { "mobile": "9876543210", "otp_type": "whatsapp" }
/// Login (Email OTP): same URL, otp_type: "mail"
/// Response: (success || isSuccess) && data.token → save as login_token
class AuthApi {
  static const String loginPath = '/auth/login';

  static final BaseAPI _api = BaseAPI();

  /// Sends OTP to [mobile] via WhatsApp or email.
  /// [otpType] must be 'whatsapp' or 'mail'.
  /// On success saves [AppStorage.loginToken] and returns (true, null).
  /// On failure returns (false, errorMessage).
  static Future<(bool success, String? errorMessage)> login({
    required String mobile,
    String otpType = 'whatsapp',
    bool showLoader = true,
  }) async {
    try {
      final response = await _api.post(
        url: loginPath,
        data: <String, dynamic>{
          'mobile': mobile,
          'otp_type': otpType,
        },
        showLoader: showLoader,
        skipAuth: true,
      );

      if (response == null) return (false, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, msg ?? 'Failed to send OTP');
      }

      final raw = response.data;
      final body = _parseBody(raw);
      if (body == null) return (false, 'Invalid response');

      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      final data = body['data'];
      final token = data is Map ? data['token'] : null;
      final tokenStr = token?.toString();
      final message = body['message']?.toString();

      if (isSuccess && tokenStr != null && tokenStr.isNotEmpty) {
        AppStorage.loginToken = tokenStr;
        return (true, null);
      }
      return (false, message ?? 'Failed to send OTP');
    } on DioException catch (e) {
      final msg = e.response != null ? _messageFromResponse(e.response!) : e.message;
      return (false, msg ?? 'Something went wrong');
    }
  }

  /// Parses response body: handles String (raw JSON) or Map from Dio.
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

  static String? _messageFromResponse(Response response) {
    try {
      final data = response.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
    } catch (_) {}
    return null;
  }
}
