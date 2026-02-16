import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

import 'base_api.dart';

/// Dashboard API from NEET Counseling API Postman collection.
/// Get Dashboard: GET {{base_url}}/dashboard with header nLoginUserIdNo.
class DashboardApi {
  static const String dashboardPath = '/dashboard';

  static final BaseAPI _api = BaseAPI();

  /// Fetches dashboard data. Sends [nLoginUserIdNo] header from [AppStorage.userId].
  /// Returns (true, data map, null) on success, (false, null, errorMessage) on failure.
  static Future<(bool success, Map<String, dynamic>? data, String? errorMessage)> getDashboard({
    bool showLoader = true,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to load dashboard');
    }
    try {
      final response = await _api.get(
        url: dashboardPath,
        headers: {'nLoginUserIdNo': userId},
        showLoader: showLoader,
      );

      if (response == null) return (false, null, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, null, msg ?? 'Failed to load dashboard');
      }

      final body = _parseBody(response.data);
      if (body == null) return (false, null, 'Invalid response');

      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      final message = body['message']?.toString();

      if (isSuccess) {
        final data = body['data'];
        if (data is Map) {
          return (true, Map<String, dynamic>.from(data), null);
        }
        return (true, body, null);
      }
      return (false, null, message ?? 'Failed to load dashboard');
    } on DioException catch (e) {
      final msg = e.response != null ? _messageFromResponse(e.response!) : e.message;
      return (false, null, msg ?? 'Something went wrong');
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

  static String? _messageFromResponse(Response response) {
    try {
      final data = response.data;
      if (data is Map && data['message'] != null) return data['message'].toString();
    } catch (_) {}
    return null;
  }
}
