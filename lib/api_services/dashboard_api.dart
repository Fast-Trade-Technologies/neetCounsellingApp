import 'dart:convert';

import 'package:dio/dio.dart';

import 'package:neetcounsellingapp/app/core/models/dashboard_models.dart';
import 'package:neetcounsellingapp/app/core/storage/app_storage.dart';

import 'base_api.dart';

/// Dashboard API from NEET Counseling API Postman collection.
/// Get Dashboard: GET {{base_url}}/dashboard with nLoginUserIdNo as query param.
class DashboardApi {
  static const String dashboardPath = '/dashboard';

  static final BaseAPI _api = BaseAPI();

  /// Fetches dashboard data. Sends [nLoginUserIdNo] as query param from [AppStorage.userId].
  /// Optional: [news_state_id], [counselling_state_id], [important_state_id] for state filters.
  /// Returns (true, DashboardData, null) on success, (false, null, errorMessage) on failure.
  static Future<(bool success, DashboardData? data, String? errorMessage)> getDashboard({
    bool showLoader = true,
    String? newsStateId,
    String? counsellingStateId,
    String? importantStateId,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to load dashboard');
    }
    try {
      final query = <String, dynamic>{'nLoginUserIdNo': userId};
      if (newsStateId != null && newsStateId.isNotEmpty) query['news_state_id'] = newsStateId;
      if (counsellingStateId != null && counsellingStateId.isNotEmpty) query['counselling_state_id'] = counsellingStateId;
      if (importantStateId != null && importantStateId.isNotEmpty) query['important_state_id'] = importantStateId;
      final response = await _api.get(
        url: dashboardPath,
        queryParameters: query,
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
        final dataRaw = body['data'];
        if (dataRaw is Map) {
          final data = DashboardData.fromJson(Map<String, dynamic>.from(dataRaw));
          return (true, data, null);
        }
        return (true, DashboardData.fromJson(null), null);
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

  /// GET dashboard/fetch-data with metric=seat_wise (default) or metric=college_wise.
  /// Params: nLoginUserIdNo, action=fetch_map_data, counselling_type_id, metric.
  /// Default metric is seat_wise; use college_wise when College Wise is selected.
  /// Returns the full "data" map (map_data, total_colleges, total_seats, institute_data, college_list when available).
  static Future<(bool success, Map<String, dynamic>? data, String? errorMessage)>
      fetchMapDataWithMetric({
    required String counsellingTypeId,
    String metric = 'seat_wise',
    bool showLoader = false,
  }) async {
    final userId = AppStorage.userId;
    if (userId == null || userId.isEmpty) {
      return (false, null, 'Please sign in to load map data');
    }
    try {
      final response = await _api.get(
        url: '$dashboardPath/fetch-data',
        queryParameters: {
          'nLoginUserIdNo': userId,
          'action': 'fetch_map_data',
          'counselling_type_id': counsellingTypeId,
          'metric': metric,
        },
        showLoader: showLoader,
      );

      if (response == null) return (false, null, 'No response from server');
      if (response.statusCode != 200) {
        final msg = _messageFromResponse(response);
        return (false, null, msg ?? 'Failed to load map data');
      }

      final body = _parseBody(response.data);
      if (body == null) return (false, null, 'Invalid response');

      final isSuccess = body['isSuccess'] == true || body['success'] == true;
      if (!isSuccess) {
        return (false, null, body['message']?.toString() ?? 'Failed to load map data');
      }

      final dataRaw = body['data'];
      if (dataRaw is Map) {
        return (true, Map<String, dynamic>.from(dataRaw), null);
      }
      return (false, null, 'Invalid data format');
    } on DioException catch (e) {
      final msg = e.response != null ? _messageFromResponse(e.response!) : e.message;
      return (false, null, msg ?? 'Something went wrong');
    }
  }
}
