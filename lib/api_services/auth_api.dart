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
  static const String verifyOtpPath = '/auth/verify-otp';
  static const String resendOtpPath = '/auth/resend-otp';
  static const String registerPath = '/auth/register';

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

  /// Verify OTP: POST {{base_url}}/auth/verify-otp
  /// Body: { "otp": "1234", "token": "{{login_token}}" }
  /// On success returns (true, null, userId). On failure returns (false, errorMessage, null).
  static Future<(bool success, String? errorMessage, String? userId)> verifyOtp({
    required String otp,
    required String token,
    bool showLoader = true,
  }) async {
    try {
      final response = await _api.post(
        url: verifyOtpPath,
        data: <String, dynamic>{'otp': otp, 'token': token},
        showLoader: showLoader,
        skipAuth: true,
      );

      if (response == null) return (false, 'No response from server', null);
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, msg ?? 'Verification failed', null);
      }

      final body = _parseBody(response.data);
      if (body == null) return (false, 'Invalid response', null);

      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      final data = body['data'];
      if (data is! Map) return (false, body['message']?.toString() ?? 'Verification failed', null);

      final userId = data['user_id']?.toString();
      final message = body['message']?.toString();

      if (isSuccess && userId != null && userId.isNotEmpty) {
        _saveVerifyOtpData(Map<String, dynamic>.from(data));
        return (true, null, userId);
      }
      return (false, message ?? 'Verification failed', null);
    } on DioException catch (e) {
      final msg = e.response != null ? _messageFromResponse(e.response!) : e.message;
      return (false, msg ?? 'Something went wrong', null);
    }
  }

  /// Resend OTP: POST {{base_url}}/auth/resend-otp
  /// Body: { "token": "{{login_token}}" }
  static Future<(bool success, String? errorMessage)> resendOtp({
    required String token,
    bool showLoader = false,
  }) async {
    try {
      final response = await _api.post(
        url: resendOtpPath,
        data: <String, dynamic>{'token': token},
        showLoader: showLoader,
        skipAuth: true,
      );

      if (response == null) return (false, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, msg ?? 'Failed to resend OTP');
      }

      final body = _parseBody(response.data);
      if (body == null) return (false, 'Invalid response');

      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      final message = body['message']?.toString();

      if (isSuccess) return (true, null);
      return (false, message ?? 'Failed to resend OTP');
    } on DioException catch (e) {
      final msg = e.response != null ? _messageFromResponse(e.response!) : e.message;
      return (false, msg ?? 'Something went wrong');
    }
  }

  /// Register: POST {{base_url}}/auth/register
  /// Body: { "first_name", "last_name", "email", "mobile", "stream": "1" }
  static Future<(bool success, String? errorMessage)> register({
    required String firstName,
    required String lastName,
    required String email,
    required String mobile,
    String stream = '1',
    bool showLoader = true,
  }) async {
    try {
      final response = await _api.post(
        url: registerPath,
        data: <String, dynamic>{
          'first_name': firstName,
          'last_name': lastName,
          'email': email,
          'mobile': mobile,
          'stream': stream,
        },
        showLoader: showLoader,
        skipAuth: true,
      );

      if (response == null) return (false, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, msg ?? 'Registration failed');
      }

      final body = _parseBody(response.data);
      if (body == null) return (false, 'Invalid response');

      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      final message = body['message']?.toString();

      if (isSuccess) return (true, null);
      return (false, message ?? 'Registration failed');
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

  /// Saves verify-otp response to local storage: user_id, token, and user object fields.
  static void _saveVerifyOtpData(Map<String, dynamic> data) {
    AppStorage.userId = data['user_id']?.toString();
    AppStorage.authToken = data['token']?.toString();

    final user = data['user'];
    if (user is Map) {
      final first = (user['first_name']?.toString() ?? '').trim();
      final last = (user['last_name']?.toString() ?? '').trim();
      AppStorage.userFirstName = first.isEmpty ? null : first;
      AppStorage.userLastName = last.isEmpty ? null : last;
      AppStorage.userName = [first, last].where((s) => s.isNotEmpty).join(' ');
      AppStorage.userPhone = user['mobile']?.toString();
      AppStorage.userEmail = user['email']?.toString();
      AppStorage.userStream = user['stream']?.toString();
      AppStorage.userPaidStatus = user['paid_status']?.toString();
      AppStorage.userImage = user['image']?.toString();
    }
  }

  static String? _messageFromResponse(Response response) {
    try {
      final data = response.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
    } catch (_) {}
    return null;
  }
}
